dir=$(dirname $(dirname $0))

schema=$(cat $dir/src/schema.graphql | tr '\n' ' ')

jq -n --arg schema "$schema" '
{
  query: "
    mutation addSchema($sch: String!) {
      addSchema(input: { schema: $sch }) {
        schema { schema }
      }
    }
  ",
  variables: { sch: $schema }
}' | curl -X POST -H "Content-Type: application/json" http://localhost:9000/admin -d @-
