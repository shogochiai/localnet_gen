tezos-client \
  -p ProtoALphaAL \
  originate contract ovm_contract \
  transferring 2.01 \
  from bootstrap1 \
  running main.tz \
  -init '`cat storage.tz`'