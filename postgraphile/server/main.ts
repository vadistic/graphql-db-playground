import express from 'express'
import { postgraphile } from 'postgraphile'
import dotenv from 'dotenv'
import path from 'path'
// @ts-ignore
import PgManyToManyPlugin from "@graphile-contrib/pg-many-to-many"


if (process.env.IS_LOCAL) {
  dotenv.config({ path: path.join(__dirname, '../.env.local',) })
} else {
  dotenv.config({ path: path.join(__dirname, '../.env.vm') })
}


const app = express()

const main = postgraphile(
  process.env.DATABASE_URL,
  process.env.DATABASE_SCHEMA!.split(','),
  {
    appendPlugins: [PgManyToManyPlugin],
    watchPg: true,
    graphiql: true,
    enhanceGraphiql: true,
  }
)

app.use(main)

app.listen(process.env.PORT, () => {
  console.log(`<rocket emoji> Server ready at...`)
})
