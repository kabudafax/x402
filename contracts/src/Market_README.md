# Market Contract Documentation

## Overview

The `Market` contract manages the service marketplace, providing service discovery and rating functionality for the x402 AI Agent Trading Platform.

## Features

### 1. Service Listing

- **List Service**: Service providers can list their services on the marketplace
- **Delist Service**: Service providers or owner can delist services
- **Update Listing**: Update listing information when service changes

### 2. Service Discovery

- **Get Services by Type**: Query services filtered by type (STRATEGY, RISK_CONTROL, DATA_SOURCE, OTHER)
- **Get All Services**: Get all listed services with pagination
- **Get Service Details**: Get detailed information about a specific service

### 3. Service Rating

- **Rate Service**: Users can rate services (1-5 stars) after using them
- **Update Rating**: Users can update their ratings
- **View Ratings**: View average rating and all ratings for a service
- **Usage Tracking**: Track service usage to verify rating eligibility

## Key Functions

### listService

```solidity
function listService(address serviceAddress) external
```

Lists a service on the marketplace. Only the service provider can list their service.

**Requirements**:
- Service must be active
- Service must not already be listed
- Caller must be the service provider

### delistService

```solidity
function delistService(address serviceAddress) external
```

Removes a service from the marketplace. Only the service provider or contract owner can delist.

### getServicesByType

```solidity
function getServicesByType(
    Service.ServiceType serviceType,
    uint256 offset,
    uint256 limit
) external view returns (address[] memory services, uint256 total)
```

Gets services filtered by type with pagination support.

**Parameters**:
- `serviceType`: Type of service to filter
- `offset`: Starting index for pagination
- `limit`: Maximum number of results

**Returns**:
- `services`: Array of service addresses
- `total`: Total number of services of this type

### rateService

```solidity
function rateService(
    address serviceAddress,
    uint256 rating,
    string memory comment
) external
```

Rates a service (1-5 stars). Users must have used the service before rating.

**Requirements**:
- Service must be listed
- Rating must be between 1 and 5
- User must have used the service (recorded via `recordServiceUsage`)

**Features**:
- Updates average rating automatically
- Allows updating existing rating
- Stores optional comment

### recordServiceUsage

```solidity
function recordServiceUsage(address serviceAddress, address user) external
```

Records that a user has used a service. This is called by Agent or Service contracts to track usage.

**Note**: In production, add access control to ensure only authorized contracts can record usage.

## Service Discovery Flow

1. **User queries services**
   - Call `getServicesByType()` or `getAllServices()`
   - Get list of service addresses

2. **User views service details**
   - Call `getServiceListing()` for each service
   - View name, description, price, rating, etc.

3. **User selects service**
   - Use service address to interact with Service contract
   - Call service via Agent contract

## Rating System

### Rating Requirements

- Users must use a service before rating
- Rating must be between 1 and 5
- Users can update their ratings

### Rating Calculation

- Average rating is calculated as: `(sum of all ratings) / (number of ratings)`
- Rating is scaled by 100 for precision (e.g., 4.5 = 450)
- Average is updated automatically when ratings change

### Rating Storage

- All ratings are stored in `ratings[serviceAddress]` array
- User's rating is also stored in `userRatings[serviceAddress][user]` for quick lookup

## Data Structures

### ServiceListing

```solidity
struct ServiceListing {
    address serviceAddress;
    string name;
    string description;
    Service.ServiceType serviceType;
    uint256 price;
    address provider;
    uint256 averageRating;  // Scaled by 100
    uint256 ratingCount;
    uint256 callCount;
    bool isListed;
    uint256 listedAt;
    uint256 updatedAt;
}
```

### Rating

```solidity
struct Rating {
    address rater;
    uint256 rating;      // 1-5
    uint256 timestamp;
    string comment;
}
```

## Events

- `ServiceListed`: When a service is listed
- `ServiceDelisted`: When a service is delisted
- `ServiceUpdated`: When listing is updated
- `ServiceRated`: When a service is rated
- `ServiceUsageRecorded`: When service usage is recorded

## Integration

### With Service Contract

The Market contract reads information from Service contracts:
- Service name, description, price
- Service type and status
- Service provider address

### With Agent Contract

The Market contract tracks service usage:
- Agent records usage when calling services
- Usage is required before rating

## Security Features

- **Access Control**: Only providers can list/update their services
- **Rating Validation**: Users must use service before rating
- **Rating Range**: Ratings must be 1-5
- **Duplicate Prevention**: Services can only be listed once

## Gas Optimization

- Services indexed by type for efficient queries
- Pagination support to limit gas costs
- Cached average rating (recalculated on rating changes)

## Future Improvements

- Service search by keyword (requires off-chain indexing)
- Service filtering by price range
- Service sorting by rating, price, usage
- Service categories and tags
- Service reviews (longer text)
- Service provider reputation
- Service analytics dashboard

## Testing

See `test/Market.t.sol` for test cases covering:
- Service listing/delisting
- Service discovery
- Service rating
- Usage tracking
- Access control

## Deployment

Deploy Market contract with owner address. No dependencies on other contracts (reads from Service contracts).

