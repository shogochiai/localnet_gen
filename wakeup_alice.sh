cd ./tezos
docker cp tz1UnFzTB3KjSXo27WfyzzpAw33jqjAdohvR.json localnet_node_1:/usr/local/tezos
scripts/localnet.sh client \
  -p ProtoALphaAL \
  activate account alice \
  with tz1UnFzTB3KjSXo27WfyzzpAw33jqjAdohvR.json --force
cd ../