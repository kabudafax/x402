import { useQuery } from '@tanstack/react-query'
import { useWeb3 } from '../hooks/useWeb3'
import { MONAD_CONFIG } from '../config/constants'

interface Transaction {
  id: string
  tx_hash: string
  transaction_type: string
  amount: string
  status: string
  created_at: string
}

export default function TransactionPage() {
  const { address, isConnected } = useWeb3()

  // In production, this would fetch from the agent's transactions
  // For now, show a placeholder
  const { data: transactions = [], isLoading } = useQuery<Transaction[]>({
    queryKey: ['transactions', address],
    queryFn: async () => {
      // Placeholder - would fetch from API
      return []
    },
    enabled: !!address && isConnected,
  })

  if (!isConnected) {
    return (
      <div className="text-center py-12">
        <p className="text-xl text-gray-400">Please connect your wallet to view transactions</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Transaction History</h1>

      {isLoading ? (
        <div className="text-center py-12">Loading transactions...</div>
      ) : transactions.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-gray-400">No transactions yet</p>
        </div>
      ) : (
        <div className="bg-gray-800 rounded-lg overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-700">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase">
                  Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase">
                  Amount
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase">
                  Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase">
                  Hash
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-700">
              {transactions.map((tx) => (
                <tr key={tx.id}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 py-1 rounded text-sm ${
                      tx.transaction_type === 'buy' ? 'bg-green-600' : 'bg-red-600'
                    }`}>
                      {tx.transaction_type}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    {parseFloat(tx.amount).toFixed(4)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 py-1 rounded text-sm ${
                      tx.status === 'success' ? 'bg-green-600' : 
                      tx.status === 'failed' ? 'bg-red-600' : 'bg-yellow-600'
                    }`}>
                      {tx.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-400">
                    {new Date(tx.created_at).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-400">
                    <a
                      href={`${MONAD_CONFIG.blockExplorer.url}/tx/${tx.tx_hash}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-blue-400 hover:text-blue-300"
                    >
                      {tx.tx_hash.slice(0, 10)}...
                    </a>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}

