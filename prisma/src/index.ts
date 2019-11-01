import { ServerResponse, IncomingMessage } from 'http'

const handler = (req: IncomingMessage, res: ServerResponse) => {
  console.log(req.url)

  res.end(`Hello`)
}

export default handler
