import { Link } from 'react-router-dom'

export default function HomePage() {
  return (
    <div className="space-y-8">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4">x402 AI Agent Trading Platform</h1>
        <p className="text-xl text-gray-400 mb-8">
          Create AI agents that autonomously trade and purchase services via x402 payments
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-gray-800 p-6 rounded-lg">
          <h2 className="text-2xl font-bold mb-4">Create Agent</h2>
          <p className="text-gray-400 mb-4">
            Deploy your AI trading agent on Monad chain
          </p>
          <Link
            to="/agents"
            className="inline-block px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded"
          >
            Get Started
          </Link>
        </div>

        <div className="bg-gray-800 p-6 rounded-lg">
          <h2 className="text-2xl font-bold mb-4">Service Market</h2>
          <p className="text-gray-400 mb-4">
            Browse and purchase AI services for your agents
          </p>
          <Link
            to="/market"
            className="inline-block px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded"
          >
            Explore Market
          </Link>
        </div>

        <div className="bg-gray-800 p-6 rounded-lg">
          <h2 className="text-2xl font-bold mb-4">View Transactions</h2>
          <p className="text-gray-400 mb-4">
            Track your agent's trading and payment history
          </p>
          <Link
            to="/transactions"
            className="inline-block px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded"
          >
            View History
          </Link>
        </div>
      </div>

      <div className="bg-gray-800 p-6 rounded-lg">
        <h2 className="text-2xl font-bold mb-4">How It Works</h2>
        <div className="space-y-4 text-left">
          <div>
            <h3 className="text-lg font-semibold mb-2">1. Create Your Agent</h3>
            <p className="text-gray-400">
              Deploy an AI agent contract on Monad chain and fund it with trading capital.
            </p>
          </div>
          <div>
            <h3 className="text-lg font-semibold mb-2">2. Purchase Services</h3>
            <p className="text-gray-400">
              Your agent can autonomously purchase services (strategy, risk control, data) using x402 payments.
            </p>
          </div>
          <div>
            <h3 className="text-lg font-semibold mb-2">3. Execute Trades</h3>
            <p className="text-gray-400">
              Agent uses purchased services to make trading decisions and execute trades automatically.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

