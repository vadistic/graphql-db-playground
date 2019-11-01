import { gql } from 'apollo-server-core';

export const typeDefs = gql`
  type Author {
    id: Int!
    firstName: String
    lastName: String
    posts: [Post]
  }

  type Post {
    id: Int!
    title: String
    author: Author
    votes: Int
  }

  type Query {
    posts: [Post]
    author(id: Int!): Author
  }
`
