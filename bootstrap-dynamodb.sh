#!/bin/bash
set -e

DIR=$(cd "$(dirname "$0")" && pwd)
BOOTSTRAP_DIR=/bootstrap
BOOTSTRAPPED=$DIR/BOOTSTRAPPED

export DYNAMO_ENDPOINT_URL=http://localhost:$DYNAMO_PORT
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=fake
export AWS_SECRET_ACCESS_KEY=fake

echo "Starting dynamodb local..."
java -Djava.library.path=$DIR/DynamoDBLocal_lib -jar $DIR/DynamoDBLocal.jar -port $DYNAMO_PORT -sharedDb &
DYNAMO_PID=$!

echo "Waiting for dynamodb local..."
while ! timeout 1 bash -c "echo > /dev/tcp/localhost/$DYNAMO_PORT" 2> /dev/null; do
  sleep 1
done

if [ ! -f "$BOOTSTRAPPED" ]; then
  echo "Bootstrapping from $BOOTSTRAP_DIR..."
  if [ "$(ls -A $BOOTSTRAP_DIR)" ]; then
    for f in $BOOTSTRAP_DIR/*; do
      case "$f" in
        *.json) echo "$0: Creating table from $f"; aws dynamodb create-table --cli-input-json "file://$f" --endpoint-url $DYNAMO_ENDPOINT_URL;;
        *.sh)   echo "$0: Running $f"; . "$f" ;;
        *)      echo "$0: Ignoring $f" ;;
      esac
      echo
    done
  else
    echo "$BOOTSTRAP_DIR empty"
  fi
  touch $BOOTSTRAPPED
  echo "Bootstrap complete"
else
  echo "Already bootstrapped. Skipping."
fi

wait $DYNAMO_PID
