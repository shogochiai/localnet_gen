cd ./tezos
./scripts/localnet.sh client \
  -p ProtoALphaAL \
  originate contract ovm_contract \
  transferring 2.01 \
  from alice \
  running container:../../ligo/main.tz \
  -init '`cat ../../ligo/storage.tz`'
cd ..