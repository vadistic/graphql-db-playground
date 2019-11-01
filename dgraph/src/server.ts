import { ApolloServer, gql, IResolvers } from 'apollo-server-express'

const typeDefs = gql`
  type Query {
    hello(name: String!): String!
  }
`

const resolvers: IResolvers<any> = {
  Query: {
    hello: (root, args) => {
      return `Hello ${args.name}`
    },
  },
}

export const server = new ApolloServer({
  debug: true,
  introspection: true,
  playground: true,
  typeDefs,
  resolvers,
})
