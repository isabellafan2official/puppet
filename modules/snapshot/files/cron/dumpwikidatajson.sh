#!/bin/bash
#############################################################
# This file is maintained by puppet!
# puppet:///modules/snapshot/cron/dumpwikidatajson.sh
#############################################################
#
# Generate a json dump for Wikidata and remove old ones.
#
# Marius Hoch < hoo@online.de >

# when/if commons or other projects are included in json entity
# dumps, this script can become dumpwikibasejson.sh with shared
# functions analogous to the rdf dumps. For now however, hardcode
# the projectName here and leave the rest alone.

projectName="wikidata"
. /usr/local/bin/wikibasedumps-shared.sh

if [[ "$1" == '--help' ]]; then
	echo -e "Usage: $0 [--continue] [lexemes]\n"
	echo -e "\t--continue\tAttempt to continue a previous dump run."

	exit
fi

continue=0
if [[ "$1" == '--continue' ]]; then
	shift
	continue=1
fi

dumpName=all
entityTypes=("--entity-type" "item" "--entity-type" "property")
minSize=58000000000 # across all shards (to be divided by $shards)
if [[ "$1" == "lexemes" ]]; then
	entityTypes=("--entity-type" "lexeme")
	dumpName=lexemes
	minSize=100000000
fi

if [ $continue -eq 0 ]; then
	# Remove old leftovers, as we start from scratch.
	rm -f $tempDir/wikidataJson$dumpName.*-batch*.gz
fi

filename=wikidata-$today-$dumpName
targetFileGzip=$targetDir/$filename.json.gz
targetFileBzip2=$targetDir/$filename.json.bz2
failureFile=/tmp/dumpwikidatajson-$dumpName-failure
mainLogFile=/var/log/wikidatadump/dumpwikidatajson-$filename-main.log

shards=8

i=0
rm -f $failureFile

getNumberOfBatchesNeeded
numberOfBatchesNeeded=$(($numberOfBatchesNeeded / $shards))
function returnWithCode { return $1; }

while [ $i -lt $shards ]; do
	(
		set -o pipefail
		errorLog=/var/log/wikidatadump/dumpwikidatajson-$filename-$i.log

		batch=0

		if [ $continue -gt 0 ]; then
			getContinueBatchNumber "$tempDir/wikidataJson$dumpName.$i-batch*.gz"
		fi

		retries=0
		while [ $batch -lt $numberOfBatchesNeeded ] && [ ! -f $failureFile ]; do
			setPerBatchVars

			echo "(`date --iso-8601=minutes`) Starting batch $batch" >> $errorLog
			# This separates the run-parts by ,\n. For this we assume the last run to not be empty, which should
			# always be the case for Wikidata (given the number of runs needed is rounded down and new pages are
			# added all the time).
			( $php $multiversionscript extensions/Wikibase/repo/maintenance/dumpJson.php \
				--wiki wikidatawiki \
				--shard $i \
				--sharding-factor $shards \
				--batch-size $(($shards * 250)) \
				--snippet 2 \
				"${entityTypes[@]}" \
				--dbgroupdefault dump \
				$firstPageIdParam \
				$lastPageIdParam; \
				dumpExitCode=$?; \
				[ $lastRun -eq 0 ] && echo ','; \
				returnWithCode $dumpExitCode ) \
				2>> $errorLog | gzip -9 > $tempDir/wikidataJson$dumpName.$i-batch$batch.gz

			exitCode=$?
			if [ $exitCode -gt 0 ]; then
				handleBatchFailure
				continue
			fi

			retries=0
			let batch++
		done
	) &
	let i++
done

wait

if [ -f $failureFile ]; then
	echo -e "\n\n(`date --iso-8601=minutes`) Giving up after a shard failed." >> $mainLogFile
	rm -f $failureFile

	exit 1
fi

# Open the json list
echo '[' | gzip -f > $tempDir/wikidataJson$dumpName.gz

minSizePerShard=$((minSize / shards))
i=0
while [ $i -lt $shards ]; do
	getTempFiles "$tempDir/wikidataJson$dumpName.$i-batch*.gz"
	getFileSize "$tempFiles"
	if (( fileSize < minSizePerShard )); then
		echo "File size for shard $i is only $fileSize, expecting at least $minSizePerShard. Aborting." >> $mainLogFile
		exit 1
	fi
	cat $tempFiles >> $tempDir/wikidataJson$dumpName.gz
	rm -f $tempFiles
	let i++
	if [ $i -lt $shards ]; then
		# Shards don't end with commas so add commas to separate them
		echo ',' | gzip -f >> $tempDir/wikidataJson$dumpName.gz
	fi
done

# Close the json list
echo -e '\n]' | gzip -f >> $tempDir/wikidataJson$dumpName.gz

mv $tempDir/wikidataJson$dumpName.gz $targetFileGzip
putDumpChecksums $targetFileGzip

# Legacy directory (with legacy naming scheme)
legacyDirectory=${cronsdir}/wikidata
ln -s "../wikibase/wikidatawiki/$today/$filename.json.gz" "$legacyDirectory/$today.json.gz"
find $legacyDirectory -name '*.json.gz' -mtime +`expr $daysToKeep + 1` -delete

# (Re-)create the link to the latest
ln -fs "$today/$filename.json.gz" "$targetDirBase/latest-$dumpName.json.gz"

# Create the bzip2 from the gzip one and update the latest-....json.bz2 link
nthreads=$(( $shards / 2))
if [ $nthreads -lt 1 ]; then
    nthreads=1
fi
gzip -dc $targetFileGzip | "$lbzip2" -n $nthreads -c > $tempDir/wikidataJson$dumpName.bz2
mv $tempDir/wikidataJson$dumpName.bz2 $targetFileBzip2
ln -fs "$today/$filename.json.bz2" "$targetDirBase/latest-$dumpName.json.bz2"
putDumpChecksums $targetFileBzip2

pruneOldLogs
runDcat
