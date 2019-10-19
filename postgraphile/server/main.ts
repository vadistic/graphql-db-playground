import express from 'express'
import { postgraphile } from 'postgraphile'
import dotenv from 'dotenv'
import path from 'path'

// https://github.com/graphile-contrib/pg-many-to-many
// @ts-ignore
import PgManyToManyPlugin from "@graphile-contrib/pg-many-to-many"

// https://github.com/graphile/pg-simplify-inflector
// @ts-ignore
import PgSimplifyInflectorPlugin from "@graphile-contrib/pg-simplify-inflector"


if (process.env.IS_LOCAL) {
  dotenv.config({ path: path.join(__dirname, '../.env.local',) })
} else {
  dotenv.config({ path: path.join(__dirname, '../.env.vm') })
}


const app = express()

const main = postgraphile(
  process.env.DATABASE_SERVER_URL,
  process.env.DATABASE_SCHEMA!.split(','),
  {
    appendPlugins: [PgManyToManyPlugin, PgSimplifyInflectorPlugin],
    watchPg: true,
    graphiql: true,
    enhanceGraphiql: true,
    simpleCollections: 'both',
    jwtPgTypeIdentifier: 'app_public.jwt_token',
    jwtSecret: process.env.JWT_SECRET,
    ignoreRBAC: false,
    ownerConnectionString: process.env.DATABASE_ADMIN_URL,
    pgDefaultRole: 'app_anonymous',

    graphileBuildOptions: {
      pgSimplifyPatch: false,
      pgSimplifyAllRows: false,
      pgShortPk: true,
    },
  }
)

app.use(main)

app.listen(process.env.PORT, () => {
  console.log(`<rocket emoji> Server ready at...`)
})
