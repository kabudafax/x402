import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import Layout from './components/Layout'
import HomePage from './pages/HomePage'
import AgentPage from './pages/AgentPage'
import MarketPage from './pages/MarketPage'
import TransactionPage from './pages/TransactionPage'
import { Web3Provider } from './hooks/useWeb3'

const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Web3Provider>
        <Router>
          <Layout>
            <Routes>
              <Route path="/" element={<HomePage />} />
              <Route path="/agents" element={<AgentPage />} />
              <Route path="/market" element={<MarketPage />} />
              <Route path="/transactions" element={<TransactionPage />} />
            </Routes>
          </Layout>
        </Router>
      </Web3Provider>
    </QueryClientProvider>
  )
}

export default App

