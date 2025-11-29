import { useState } from 'react'
import { useWeb3 } from '../hooks/useWeb3'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { API_CONFIG } from '../config/constants'

interface Agent {
  id: string
  name: string
  contract_address: string
  balance: string
  status: string
}

export default function AgentPage() {
  const { address, isConnected } = useWeb3()
  const queryClient = useQueryClient()
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [agentName, setAgentName] = useState('')
  const [agentDescription, setAgentDescription] = useState('')

  // Fetch user agents
  const { data: agents = [], isLoading } = useQuery<Agent[]>({
    queryKey: ['agents', address],
    queryFn: async () => {
      if (!address) return []
      const response = await fetch(`${API_CONFIG.baseUrl}${API_CONFIG.apiVersion}/users/${address}/agents`)
      if (!response.ok) return []
      return response.json()
    },
    enabled: !!address,
  })

  // Create agent mutation
  const createAgentMutation = useMutation({
    mutationFn: async (data: { name: string; description: string; contract_address: string }) => {
      const response = await fetch(`${API_CONFIG.baseUrl}${API_CONFIG.apiVersion}/agents`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_wallet_address: address,
          ...data,
        }),
      })
      if (!response.ok) throw new Error('Failed to create agent')
      return response.json()
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['agents'] })
      setShowCreateForm(false)
      setAgentName('')
      setAgentDescription('')
    },
  })

  const handleCreateAgent = async () => {
    if (!isConnected) {
      alert('Please connect your wallet first')
      return
    }

    // In production, this would deploy the contract first
    // For now, use a placeholder address
    const contractAddress = `0x${Math.random().toString(16).substr(2, 40)}`

    createAgentMutation.mutate({
      name: agentName,
      description: agentDescription,
      contract_address: contractAddress,
    })
  }

  if (!isConnected) {
    return (
      <div className="text-center py-12">
        <p className="text-xl text-gray-400 mb-4">Please connect your wallet to manage agents</p>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold">My Agents</h1>
        <button
          onClick={() => setShowCreateForm(!showCreateForm)}
          className="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded"
        >
          {showCreateForm ? 'Cancel' : 'Create Agent'}
        </button>
      </div>

      {showCreateForm && (
        <div className="bg-gray-800 p-6 rounded-lg">
          <h2 className="text-xl font-bold mb-4">Create New Agent</h2>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-2">Agent Name</label>
              <input
                type="text"
                value={agentName}
                onChange={(e) => setAgentName(e.target.value)}
                className="w-full px-4 py-2 bg-gray-700 rounded text-white"
                placeholder="My Trading Agent"
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Description</label>
              <textarea
                value={agentDescription}
                onChange={(e) => setAgentDescription(e.target.value)}
                className="w-full px-4 py-2 bg-gray-700 rounded text-white"
                rows={3}
                placeholder="Agent description..."
              />
            </div>
            <button
              onClick={handleCreateAgent}
              disabled={!agentName || createAgentMutation.isPending}
              className="px-4 py-2 bg-green-600 hover:bg-green-700 rounded disabled:opacity-50"
            >
              {createAgentMutation.isPending ? 'Creating...' : 'Create Agent'}
            </button>
          </div>
        </div>
      )}

      {isLoading ? (
        <div className="text-center py-12">Loading agents...</div>
      ) : agents.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-gray-400">No agents yet. Create your first agent!</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {agents.map((agent) => (
            <div key={agent.id} className="bg-gray-800 p-6 rounded-lg">
              <h3 className="text-xl font-bold mb-2">{agent.name}</h3>
              <p className="text-sm text-gray-400 mb-4">
                {agent.contract_address.slice(0, 10)}...{agent.contract_address.slice(-8)}
              </p>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-gray-400">Balance:</span>
                  <span className="font-semibold">{parseFloat(agent.balance).toFixed(2)} USDC</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Status:</span>
                  <span className={`font-semibold ${
                    agent.status === 'active' ? 'text-green-400' : 'text-yellow-400'
                  }`}>
                    {agent.status}
                  </span>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

