import express from 'express'
import dotenv from 'dotenv'

dotenv.config()

import { server } from './server'

const main = async () => {
  const app = express()

  server.applyMiddleware({ app })

  app.listen({ port: 4000 }, () =>
    console.log(`🚀 Server ready at http://localhost:4000${server.graphqlPath}`),
  )
}

main()
