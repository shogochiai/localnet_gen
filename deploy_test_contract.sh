cd ./tezos
./scripts/localnet.sh client \
  originate contract ovm_contract \
  for my_identity transferring 2.01 \
  from my_account running container:../../ligo/main.tz \
  -init '`cat ../../ligo/storage.tz`'
cd ..