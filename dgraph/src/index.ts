import * as dgraph from 'dgraph-js'
import grpc from 'grpc'
import dotenv from 'dotenv'

dotenv.config()

// Create a client stub.
const newClientStub = (): dgraph.DgraphClientStub => {
  return new dgraph.DgraphClientStub(`${process.env.HOST}:9080`, grpc.credentials.createInsecure())
}

// Create a client.
const newClient = (clientStub: dgraph.DgraphClientStub) => {
  return new dgraph.DgraphClient(clientStub)
}

// Drop All - discard all data and start from a clean slate.
const dropAll = async (dgraphClient: dgraph.DgraphClient) => {
  const op = new dgraph.Operation()
  op.setDropAll(true)
  await dgraphClient.alter(op)
}

const setSchema = async (dgraphClient: dgraph.DgraphClient) => {
  const schema = `
  type Student {
    name: string
    dob: datetime
    home_address: string
    year: int
  }

    name: string @index(exact) .
    age: int .
    married: bool .
    loc: geo .
    dob: datetime .
    friend: [uid] @reverse .
  `

  const op = new dgraph.Operation()

  op.setSchema(schema)

  const res = await dgraphClient.alter(op)
}

// Create data using JSON.
const createData = async (dgraphClient: dgraph.DgraphClient) => {
  // Create a new transaction.
  const txn = dgraphClient.newTxn()

  try {
    // Create data.
    const p = [
      {
        uid: '_:alice',
        name: 'Alice',
        age: 26,
        married: true,
        loc: {
          type: 'Point',
          coordinates: [1.1, 2],
        },
        dob: new Date(1980, 1, 1, 23, 0, 0, 0),
        friend: [
          {
            name: 'Bob',
            age: 24,
          },
          {
            name: 'Charlie',
            age: 29,
          },
        ],
        school: [
          {
            name: 'Crown Public School',
          },
        ],
      },
      {
        uid: '_:bob',
        'dgraph.type': 'Student',
        name: 'Bob',
        year: 2,
      },
    ]

    // Run mutation.
    const mu = new dgraph.Mutation()

    mu.setSetJson(p)

    const assigned = await txn.mutate(mu)

    await txn.commit()
  } finally {
    await txn.discard()
  }
}

const querySchema = async (dgraphClient: dgraph.DgraphClient) => {
  const query = `
    schema {
      type
      index
      reverse
      tokenizer
      list
      count
      upsert
      lang
    }
  `
  const txn = await dgraphClient.newTxn()

  const res = await txn.query(query)

  console.log('QUERY_SCHEMA')
  console.log(res.getJson())
  console.log(res.toObject())

  txn.discard()
}

const queryData = async (dgraphClient: dgraph.DgraphClient) => {
  // Run query.
  const query = `query all($a: string) {
        all(func: eq(name, $a)) {
            uid
            name
            age
            married
            loc
            dob
            friend {
                name
                age
            }
            school {
                name
            }
        }
    }`
  const vars = { $a: 'Alice' }
  const res = await dgraphClient.newTxn().queryWithVars(query, vars)

  const ppl = res.getJson()

  console.log(`Number of people named "Alice": ${ppl.all.length}`)
  ppl.all.forEach((person: any) => console.log(person))
}

const queryType = async (dgraphClient: dgraph.DgraphClient) => {
  // Run query.
  const query = `
    {
      q(func: type(Student)) {
        name
        dob
        home_address
        year
      }
    }
    `

  const tsx = dgraphClient.newTxn()

  const res = await tsx.query(query)

  console.log('QUERY TYPE')
  console.log(res.getJson())

  await tsx.discard()

  return res
}

const main = async () => {
  const dgraphClientStub = newClientStub()
  const dgraphClient = newClient(dgraphClientStub)

  dgraphClient.setDebugMode(false)

  await dropAll(dgraphClient)
  await setSchema(dgraphClient)
  await querySchema(dgraphClient)
  await createData(dgraphClient)

  await queryType(dgraphClient)

  // await queryData(dgraphClient)

  // Close the client stub.
  dgraphClientStub.close()
}

main()
  .then(() => {
    console.log('DONE!')
  })
  .catch(e => {
    console.log('ERROR: ', e)
  })
