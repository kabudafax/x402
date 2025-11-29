import { ReactNode } from 'react'
import { Link } from 'react-router-dom'
import { useWeb3 } from '../hooks/useWeb3'

interface LayoutProps {
  children: ReactNode
}

export default function Layout({ children }: LayoutProps) {
  const { address, connect, disconnect, isConnected } = useWeb3()

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <nav className="bg-gray-800 border-b border-gray-700">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex items-center space-x-8">
              <Link to="/" className="text-xl font-bold text-blue-400">
                x402 AI Agent Trading
              </Link>
              <Link to="/agents" className="text-gray-300 hover:text-white">
                Agents
              </Link>
              <Link to="/market" className="text-gray-300 hover:text-white">
                Market
              </Link>
              <Link to="/transactions" className="text-gray-300 hover:text-white">
                Transactions
              </Link>
            </div>
            <div className="flex items-center">
              {isConnected ? (
                <div className="flex items-center space-x-4">
                  <span className="text-sm text-gray-300">
                    {address?.slice(0, 6)}...{address?.slice(-4)}
                  </span>
                  <button
                    onClick={disconnect}
                    className="px-4 py-2 bg-red-600 hover:bg-red-700 rounded"
                  >
                    Disconnect
                  </button>
                </div>
              ) : (
                <button
                  onClick={connect}
                  className="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded"
                >
                  Connect Wallet
                </button>
              )}
            </div>
          </div>
        </div>
      </nav>
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {children}
      </main>
    </div>
  )
}

