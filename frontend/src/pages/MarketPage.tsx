import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { API_CONFIG, SERVICE_TYPES } from '../config/constants'

interface Service {
  id: string
  contract_address: string
  name: string
  description: string
  service_type: string
  price: string
  rating: number
  call_count: number
  provider_address: string
}

export default function MarketPage() {
  const [selectedType, setSelectedType] = useState<string>('')
  const [searchQuery, setSearchQuery] = useState('')

  const { data: services = [], isLoading } = useQuery<Service[]>({
    queryKey: ['market-services', selectedType],
    queryFn: async () => {
      const params = new URLSearchParams()
      if (selectedType) params.append('service_type', selectedType)
      const response = await fetch(
        `${API_CONFIG.baseUrl}${API_CONFIG.apiVersion}/market/services?${params}`
      )
      if (!response.ok) return []
      return response.json()
    },
  })

  const filteredServices = services.filter((service) =>
    service.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    service.description.toLowerCase().includes(searchQuery.toLowerCase())
  )

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Service Market</h1>

      <div className="flex flex-col md:flex-row gap-4">
        <input
          type="text"
          placeholder="Search services..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="flex-1 px-4 py-2 bg-gray-800 rounded text-white"
        />
        <select
          value={selectedType}
          onChange={(e) => setSelectedType(e.target.value)}
          className="px-4 py-2 bg-gray-800 rounded text-white"
        >
          <option value="">All Types</option>
          <option value={SERVICE_TYPES.STRATEGY}>Strategy</option>
          <option value={SERVICE_TYPES.RISK_CONTROL}>Risk Control</option>
          <option value={SERVICE_TYPES.DATA_SOURCE}>Data Source</option>
          <option value={SERVICE_TYPES.OTHER}>Other</option>
        </select>
      </div>

      {isLoading ? (
        <div className="text-center py-12">Loading services...</div>
      ) : filteredServices.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-gray-400">No services found</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredServices.map((service) => (
            <div key={service.id} className="bg-gray-800 p-6 rounded-lg">
              <div className="flex justify-between items-start mb-2">
                <h3 className="text-xl font-bold">{service.name}</h3>
                <span className="px-2 py-1 bg-blue-600 rounded text-sm">
                  {service.service_type}
                </span>
              </div>
              <p className="text-gray-400 text-sm mb-4 line-clamp-2">
                {service.description}
              </p>
              <div className="space-y-2 mb-4">
                <div className="flex justify-between">
                  <span className="text-gray-400">Price:</span>
                  <span className="font-semibold">
                    {parseFloat(service.price).toFixed(2)} USDC
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Rating:</span>
                  <span className="font-semibold">
                    {service.rating > 0 ? '⭐'.repeat(Math.round(service.rating)) : 'No ratings'}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-400">Calls:</span>
                  <span className="font-semibold">{service.call_count}</span>
                </div>
              </div>
              <button className="w-full px-4 py-2 bg-green-600 hover:bg-green-700 rounded">
                Purchase Service
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

