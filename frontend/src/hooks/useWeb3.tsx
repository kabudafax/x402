import { createContext, useContext, useState, useEffect, ReactNode } from 'react'
import { createPublicClient, http, createWalletClient, custom, formatEther } from 'viem'
import { monadTestnet } from 'viem/chains'
import { MONAD_CONFIG } from '../config/constants'

interface Web3ContextType {
  address: string | undefined
  isConnected: boolean
  connect: () => Promise<void>
  disconnect: () => void
  publicClient: ReturnType<typeof createPublicClient> | null
  walletClient: ReturnType<typeof createWalletClient> | null
}

const Web3Context = createContext<Web3ContextType | undefined>(undefined)

export function Web3Provider({ children }: { children: ReactNode }) {
  const [address, setAddress] = useState<string | undefined>()
  const [publicClient, setPublicClient] = useState<ReturnType<typeof createPublicClient> | null>(null)
  const [walletClient, setWalletClient] = useState<ReturnType<typeof createWalletClient> | null>(null)

  useEffect(() => {
    // Initialize public client
    const client = createPublicClient({
      chain: {
        id: MONAD_CONFIG.chainId,
        name: MONAD_CONFIG.name,
        nativeCurrency: MONAD_CONFIG.currency,
        rpcUrls: {
          default: {
            http: [MONAD_CONFIG.rpcUrl],
          },
        },
      },
      transport: http(),
    })
    setPublicClient(client)
  }, [])

  const connect = async () => {
    if (typeof window.ethereum !== 'undefined') {
      try {
        const [account] = await window.ethereum.request({
          method: 'eth_requestAccounts',
        })
        setAddress(account)

        const wallet = createWalletClient({
          account: account as `0x${string}`,
          chain: {
            id: MONAD_CONFIG.chainId,
            name: MONAD_CONFIG.name,
            nativeCurrency: MONAD_CONFIG.currency,
            rpcUrls: {
              default: {
                http: [MONAD_CONFIG.rpcUrl],
              },
            },
          },
          transport: custom(window.ethereum),
        })
        setWalletClient(wallet)
      } catch (error) {
        console.error('Failed to connect wallet:', error)
      }
    } else {
      alert('Please install MetaMask or another Web3 wallet')
    }
  }

  const disconnect = () => {
    setAddress(undefined)
    setWalletClient(null)
  }

  useEffect(() => {
    // Check if already connected
    if (typeof window.ethereum !== 'undefined') {
      window.ethereum.request({ method: 'eth_accounts' }).then((accounts: string[]) => {
        if (accounts.length > 0) {
          setAddress(accounts[0])
        }
      })
    }
  }, [])

  return (
    <Web3Context.Provider
      value={{
        address,
        isConnected: !!address,
        connect,
        disconnect,
        publicClient,
        walletClient,
      }}
    >
      {children}
    </Web3Context.Provider>
  )
}

export function useWeb3() {
  const context = useContext(Web3Context)
  if (context === undefined) {
    throw new Error('useWeb3 must be used within a Web3Provider')
  }
  return context
}

// Extend Window interface
declare global {
  interface Window {
    ethereum?: any
  }
}

