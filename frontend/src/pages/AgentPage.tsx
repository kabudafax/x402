import { useState } from 'react'
import { useWeb3 } from '../hooks/useWeb3'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { API_CONFIG, CONTRACT_ADDRESSES } from '../config/constants'
import { encodeDeployData, encodeFunctionData, formatUnits, parseUnits } from 'viem'
import AgentContract from '../contracts/AgentFull.json'
import { getContract } from 'viem'

interface Agent {
  id: string
  name: string
  contract_address: string
  balance: string
  status: string
}

export default function AgentPage() {
  const { address, isConnected, walletClient, publicClient } = useWeb3()
  const queryClient = useQueryClient()
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [agentName, setAgentName] = useState('')
  const [agentDescription, setAgentDescription] = useState('')
  const [paymentTokenAddress, setPaymentTokenAddress] = useState('')
  const [isDeploying, setIsDeploying] = useState(false)
  const [depositAmount, setDepositAmount] = useState('')
  const [selectedAgent, setSelectedAgent] = useState<string | null>(null)

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

  // Fetch agent balance
  const { data: agentBalance, refetch: refetchBalance } = useQuery({
    queryKey: ['agent-balance', selectedAgent],
    queryFn: async () => {
      if (!selectedAgent || !publicClient) return null
      try {
        const contract = getContract({
          address: selectedAgent as `0x${string}`,
          abi: AgentContract.abi as any,
          client: publicClient,
        })
        // Get payment token address from contract
        const paymentToken = await contract.read.paymentToken() as `0x${string}`
        // Get balance
        const balance = await contract.read.getBalance([paymentToken]) as bigint
        return { balance, paymentToken }
      } catch (error) {
        console.error('Failed to fetch balance:', error)
        return null
      }
    },
    enabled: !!selectedAgent && !!publicClient,
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
    if (!isConnected || !address) {
      alert('Please connect your wallet first')
      return
    }

    if (!walletClient || !publicClient) {
      alert('Wallet not initialized')
      return
    }

    if (!CONTRACT_ADDRESSES.X402_PAYMENT) {
      alert('X402 Payment Handler address not configured. Please set VITE_X402_PAYMENT_CONTRACT in .env')
      return
    }

    if (!paymentTokenAddress || !paymentTokenAddress.startsWith('0x')) {
      alert('Please enter a valid payment token address')
      return
    }

    setIsDeploying(true)

    try {
      // Deploy Agent contract
      const deployData = encodeDeployData({
        abi: AgentContract.abi as any,
        bytecode: AgentContract.bytecode as `0x${string}`,
        args: [
          CONTRACT_ADDRESSES.X402_PAYMENT as `0x${string}`,
          paymentTokenAddress as `0x${string}`,
          address as `0x${string}`,
        ],
      })

      const hash = await walletClient.sendTransaction({
        data: deployData,
        account: address as `0x${string}`,
      })

      // Wait for transaction receipt
      const receipt = await publicClient.waitForTransactionReceipt({ hash })
      
      if (!receipt.contractAddress) {
        throw new Error('Contract deployment failed: no contract address in receipt')
      }

      const contractAddress = receipt.contractAddress

      // Create agent record in backend
      createAgentMutation.mutate({
        name: agentName,
        description: agentDescription,
        contract_address: contractAddress,
      })
    } catch (error: any) {
      console.error('Failed to deploy agent contract:', error)
      alert(`Failed to deploy agent contract: ${error.message || 'Unknown error'}`)
    } finally {
      setIsDeploying(false)
    }
  }

  const handleDeposit = async (agentAddress: string) => {
    if (!walletClient || !publicClient || !address) {
      alert('Wallet not initialized')
      return
    }

    if (!depositAmount || parseFloat(depositAmount) <= 0) {
      alert('Please enter a valid amount')
      return
    }

    try {
      const contract = getContract({
        address: agentAddress as `0x${string}`,
        abi: AgentContract.abi as any,
        client: { public: publicClient, wallet: walletClient },
      })

      // Get payment token address
      const paymentToken = await contract.read.paymentToken() as `0x${string}`
      
      // For ERC20 tokens, we need to approve first, then call deposit
      // This is simplified - in production, you'd need ERC20 ABI for approval
      const amount = parseUnits(depositAmount, 18) // Assuming 18 decimals
      
      const hash = await contract.write.deposit([paymentToken, amount], {
        account: address as `0x${string}`,
      })

      await publicClient.waitForTransactionReceipt({ hash })
      alert('Deposit successful!')
      setDepositAmount('')
      refetchBalance()
    } catch (error: any) {
      console.error('Failed to deposit:', error)
      alert(`Failed to deposit: ${error.message || 'Unknown error'}`)
    }
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
            <div>
              <label className="block text-sm font-medium mb-2">
                Payment Token Address <span className="text-red-400">*</span>
              </label>
              <input
                type="text"
                value={paymentTokenAddress}
                onChange={(e) => setPaymentTokenAddress(e.target.value)}
                className="w-full px-4 py-2 bg-gray-700 rounded text-white font-mono text-sm"
                placeholder="0x..."
              />
              <p className="text-xs text-gray-400 mt-1">
                Address of the ERC20 token to use for payments (e.g., USDC)
              </p>
            </div>
            {!CONTRACT_ADDRESSES.X402_PAYMENT && (
              <div className="bg-yellow-900/30 border border-yellow-600 rounded p-3 text-sm text-yellow-200">
                ⚠️ X402 Payment Handler address not configured. Please set VITE_X402_PAYMENT_CONTRACT in .env
              </div>
            )}
            <button
              onClick={handleCreateAgent}
              disabled={!agentName || !paymentTokenAddress || isDeploying || createAgentMutation.isPending || !CONTRACT_ADDRESSES.X402_PAYMENT}
              className="px-4 py-2 bg-green-600 hover:bg-green-700 rounded disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isDeploying ? 'Deploying Contract...' : createAgentMutation.isPending ? 'Creating...' : 'Deploy & Create Agent'}
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
              <p className="text-sm text-gray-400 mb-4 font-mono">
                {agent.contract_address.slice(0, 10)}...{agent.contract_address.slice(-8)}
              </p>
              <div className="space-y-2 mb-4">
                <div className="flex justify-between">
                  <span className="text-gray-400">Balance:</span>
                  <span className="font-semibold">
                    {selectedAgent === agent.contract_address && agentBalance
                      ? formatUnits(agentBalance.balance, 18)
                      : parseFloat(agent.balance).toFixed(2)} USDC
                  </span>
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
              <div className="space-y-2">
                <button
                  onClick={() => {
                    setSelectedAgent(agent.contract_address)
                    refetchBalance()
                  }}
                  className="w-full px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded text-sm"
                >
                  Refresh Balance
                </button>
                {selectedAgent === agent.contract_address && (
                  <div className="mt-2 space-y-2">
                    <input
                      type="number"
                      value={depositAmount}
                      onChange={(e) => setDepositAmount(e.target.value)}
                      placeholder="Amount to deposit"
                      className="w-full px-3 py-2 bg-gray-700 rounded text-white text-sm"
                    />
                    <button
                      onClick={() => handleDeposit(agent.contract_address)}
                      className="w-full px-4 py-2 bg-green-600 hover:bg-green-700 rounded text-sm"
                    >
                      Deposit
                    </button>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

