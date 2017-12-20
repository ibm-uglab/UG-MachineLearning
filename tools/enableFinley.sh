#!/bin/bash
source /opt/IBM/InformationServer/UGDockerDeployment/installer/uginfo.rsp
rm -rf /tmp/odfconfig.json
FINLEY_HOST=$MASTER_NODE_HOST
FINLEY_PORT=32500
ODFCONFIG=/tmp/odfconfig.json
/opt/IBM/InformationServer/ASBNode/bin/IAAdmin.sh -user $IS_ADMIN_USER -password $IS_ADMIN_PASSWORD -url https://localhost:$IS_SERVER_PORT -getODFParams >/tmp/odfconfig.json
echo '---- Created json file: odfconfig.json with ODF parameters ----'
if grep -q "endpoint" $ODFCONFIG; then
   sed -i 's/\"endpoint\"\s*:\s*\"[^"]*/\"endpoint\":\"'"$FINLEY_HOST"':'"$FINLEY_PORT"'/g' $ODFCONFIG
elif grep -q "FinleyPredictorService" $ODFCONFIG; then
   sed -i 's/FinleyPredictorService\"\s*:{/FinleyPredictorService\":{\n\"endpoint\":\"'"$FINLEY_HOST"':'"$FINLEY_PORT"'\",/g' $ODFCONFIG
elif grep -q "services\"\s*:\s*{" $ODFCONFIG; then
   sed -i 's/services\s*\"\s*:\s*{/services\":{\n\"com.ibm.iis.odf.services.termassignment.finley.FinleyPredictorService\":{\n\"endpoint\":\"'"$FINLEY_HOST"':'"$FINLEY_PORT"'\",\n\"maxWaitForConnection\":5,\n\"maxWaitForData\":3\n},/g' $ODFCONFIG
else
   echo 'No plug point for Finley service found in configuration. Not changed.'
fi
/opt/IBM/InformationServer/ASBNode/bin/IAAdmin.sh -user $IS_ADMIN_USER -password $IS_ADMIN_PASSWORD -url https://localhost:$IS_SERVER_PORT -setODFParams -content /tmp/odfconfig.json
echo '----- Setting ODF parameters -----'
/opt/IBM/InformationServer/ASBServer/bin/iisAdmin.sh -set -key com.ibm.iis.ug11_7.odfservices.ta -value "com.ibm.iis.odf.services.termassignment.finley.FinleyPredictorService,com.ibm.iis.odf.services.termclassification.matching.bg.MatcherDiscoveryService,com.ibm.iis.odf.iisext.services.cbta.ClassBasedTermAssignmentService"
echo '----- All set to use Finley -----'
