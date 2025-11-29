// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Service} from "./Service.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Market
 * @notice Service marketplace contract for discovering and rating services
 * @dev Manages service listings, discovery, and ratings
 */
contract Market is ReentrancyGuard, Ownable {
    // ============ Structs ============

    /// @notice Service listing information
    struct ServiceListing {
        address serviceAddress;         // Service contract address
        string name;                    // Service name
        string description;             // Service description
        Service.ServiceType serviceType; // Service type
        uint256 price;                  // Service price
        address provider;               // Service provider
        uint256 averageRating;         // Average rating (1-5, scaled by 100)
        uint256 ratingCount;            // Number of ratings
        uint256 callCount;              // Total call count
        bool isListed;                  // Whether service is listed
        uint256 listedAt;                // Listing timestamp
        uint256 updatedAt;               // Last update timestamp
    }

    /// @notice Rating information
    struct Rating {
        address rater;                  // Address that rated
        uint256 rating;                 // Rating value (1-5)
        uint256 timestamp;              // Rating timestamp
        string comment;                 // Optional comment
    }

    // ============ State Variables ============

    /// @notice Service listings (service address => listing)
    mapping(address => ServiceListing) public listings;

    /// @notice Service addresses by type (for discovery)
    mapping(Service.ServiceType => address[]) public servicesByType;

    /// @notice All listed service addresses
    address[] public allServices;

    /// @notice Ratings for each service (service address => ratings)
    mapping(address => Rating[]) public ratings;

    /// @notice User ratings (service address => user address => rating)
    mapping(address => mapping(address => Rating)) public userRatings;

    /// @notice Service usage tracking (service address => user address => usage count)
    mapping(address => mapping(address => uint256)) public serviceUsage;

    /// @notice Minimum rating value
    uint256 public constant MIN_RATING = 1;

    /// @notice Maximum rating value
    uint256 public constant MAX_RATING = 5;

    /// @notice Rating scale (for precision)
    uint256 public constant RATING_SCALE = 100;

    // ============ Events ============

    event ServiceListed(
        address indexed serviceAddress,
        string name,
        Service.ServiceType serviceType,
        address indexed provider
    );
    event ServiceDelisted(
        address indexed serviceAddress,
        address indexed provider
    );
    event ServiceUpdated(
        address indexed serviceAddress,
        string name,
        uint256 price
    );
    event ServiceRated(
        address indexed serviceAddress,
        address indexed rater,
        uint256 rating,
        string comment
    );
    event ServiceUsageRecorded(
        address indexed serviceAddress,
        address indexed user,
        uint256 usageCount
    );

    // ============ Modifiers ============

    modifier onlyListed(address serviceAddress) {
        require(
            listings[serviceAddress].isListed,
            "Market: Service not listed"
        );
        _;
    }

    modifier validRating(uint256 rating) {
        require(
            rating >= MIN_RATING && rating <= MAX_RATING,
            "Market: Invalid rating"
        );
        _;
    }

    // ============ Constructor ============

    constructor(address _owner) Ownable(_owner) {}

    // ============ Service Listing ============

    /**
     * @notice List a service on the marketplace
     * @param serviceAddress Service contract address
     */
    function listService(address serviceAddress) external {
        require(serviceAddress != address(0), "Market: Invalid service address");
        require(
            !listings[serviceAddress].isListed,
            "Market: Service already listed"
        );

        // Verify service contract exists and get info
        Service service = Service(serviceAddress);
        Service.ServiceInfo memory serviceInfo = service.getServiceInfo();

        require(
            serviceInfo.status == Service.ServiceStatus.ACTIVE,
            "Market: Service not active"
        );
        require(
            msg.sender == serviceInfo.provider,
            "Market: Not service provider"
        );

        // Create listing
        listings[serviceAddress] = ServiceListing({
            serviceAddress: serviceAddress,
            name: serviceInfo.name,
            description: serviceInfo.description,
            serviceType: serviceInfo.serviceType,
            price: serviceInfo.price,
            provider: serviceInfo.provider,
            averageRating: 0,
            ratingCount: 0,
            callCount: 0,
            isListed: true,
            listedAt: block.timestamp,
            updatedAt: block.timestamp
        });

        // Add to type index
        servicesByType[serviceInfo.serviceType].push(serviceAddress);
        allServices.push(serviceAddress);

        emit ServiceListed(
            serviceAddress,
            serviceInfo.name,
            serviceInfo.serviceType,
            serviceInfo.provider
        );
    }

    /**
     * @notice Delist a service from the marketplace
     * @param serviceAddress Service contract address
     */
    function delistService(address serviceAddress) external onlyListed(serviceAddress) {
        ServiceListing storage listing = listings[serviceAddress];
        
        require(
            msg.sender == listing.provider || msg.sender == owner(),
            "Market: Not authorized"
        );

        listing.isListed = false;
        listing.updatedAt = block.timestamp;

        emit ServiceDelisted(serviceAddress, listing.provider);
    }

    /**
     * @notice Update service listing information
     * @param serviceAddress Service contract address
     */
    function updateListing(address serviceAddress) external onlyListed(serviceAddress) {
        Service service = Service(serviceAddress);
        Service.ServiceInfo memory serviceInfo = service.getServiceInfo();

        ServiceListing storage listing = listings[serviceAddress];
        
        require(
            msg.sender == listing.provider,
            "Market: Not service provider"
        );

        listing.name = serviceInfo.name;
        listing.description = serviceInfo.description;
        listing.price = serviceInfo.price;
        listing.updatedAt = block.timestamp;

        emit ServiceUpdated(serviceAddress, serviceInfo.name, serviceInfo.price);
    }

    // ============ Service Discovery ============

    /**
     * @notice Get services by type with pagination
     * @param serviceType Service type to filter
     * @param offset Starting index
     * @param limit Maximum number of results
     * @return services Array of service addresses
     * @return total Total number of services of this type
     */
    function getServicesByType(
        Service.ServiceType serviceType,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory services, uint256 total) {
        address[] memory allTypeServices = servicesByType[serviceType];
        total = 0;

        // Count listed services
        for (uint256 i = 0; i < allTypeServices.length; i++) {
            if (listings[allTypeServices[i]].isListed) {
                total++;
            }
        }

        // Calculate result size
        uint256 resultSize = offset + limit > total ? total - offset : limit;
        if (resultSize > total) resultSize = 0;

        services = new address[](resultSize);
        uint256 count = 0;
        uint256 added = 0;

        // Collect listed services
        for (uint256 i = 0; i < allTypeServices.length && added < resultSize; i++) {
            if (listings[allTypeServices[i]].isListed) {
                if (count >= offset) {
                    services[added] = allTypeServices[i];
                    added++;
                }
                count++;
            }
        }
    }

    /**
     * @notice Get all services with pagination
     * @param offset Starting index
     * @param limit Maximum number of results
     * @return services Array of service addresses
     * @return total Total number of listed services
     */
    function getAllServices(
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory services, uint256 total) {
        // Count listed services
        total = 0;
        for (uint256 i = 0; i < allServices.length; i++) {
            if (listings[allServices[i]].isListed) {
                total++;
            }
        }

        // Calculate result size
        uint256 resultSize = offset + limit > total ? total - offset : limit;
        if (resultSize > total) resultSize = 0;

        services = new address[](resultSize);
        uint256 count = 0;
        uint256 added = 0;

        // Collect listed services
        for (uint256 i = 0; i < allServices.length && added < resultSize; i++) {
            if (listings[allServices[i]].isListed) {
                if (count >= offset) {
                    services[added] = allServices[i];
                    added++;
                }
                count++;
            }
        }
    }

    /**
     * @notice Get service listing details
     * @param serviceAddress Service contract address
     * @return listing Service listing information
     */
    function getServiceListing(
        address serviceAddress
    ) external view returns (ServiceListing memory listing) {
        return listings[serviceAddress];
    }

    // ============ Service Rating ============

    /**
     * @notice Rate a service (1-5 stars)
     * @param serviceAddress Service contract address
     * @param rating Rating value (1-5)
     * @param comment Optional comment
     */
    function rateService(
        address serviceAddress,
        uint256 rating,
        string memory comment
    ) external onlyListed(serviceAddress) validRating(rating) {
        ServiceListing storage listing = listings[serviceAddress];

        // Verify user has used the service
        require(
            serviceUsage[serviceAddress][msg.sender] > 0,
            "Market: Must use service before rating"
        );

        // Check if user already rated
        Rating memory existingRating = userRatings[serviceAddress][msg.sender];
        
        Rating memory newRating = Rating({
            rater: msg.sender,
            rating: rating,
            timestamp: block.timestamp,
            comment: comment
        });

        if (existingRating.timestamp == 0) {
            // New rating
            listing.ratingCount += 1;
            ratings[serviceAddress].push(newRating);
        } else {
            // Update existing rating
            // Find and update in ratings array
            for (uint256 i = 0; i < ratings[serviceAddress].length; i++) {
                if (ratings[serviceAddress][i].rater == msg.sender) {
                    ratings[serviceAddress][i] = newRating;
                    break;
                }
            }
        }

        // Update user rating mapping
        userRatings[serviceAddress][msg.sender] = newRating;

        // Recalculate average rating
        uint256 totalRating = 0;
        for (uint256 i = 0; i < ratings[serviceAddress].length; i++) {
            totalRating += ratings[serviceAddress][i].rating;
        }
        listing.averageRating = (totalRating * RATING_SCALE) / listing.ratingCount;

        emit ServiceRated(serviceAddress, msg.sender, rating, comment);
    }

    /**
     * @notice Record service usage (called by Agent or Service)
     * @param serviceAddress Service contract address
     * @param user User address (Agent contract)
     */
    function recordServiceUsage(
        address serviceAddress,
        address user
    ) external {
        // Only allow Service contract or Agent contract to record usage
        // In production, add access control
        serviceUsage[serviceAddress][user] += 1;
        
        ServiceListing storage listing = listings[serviceAddress];
        if (listing.isListed) {
            listing.callCount += 1;
        }

        emit ServiceUsageRecorded(serviceAddress, user, serviceUsage[serviceAddress][user]);
    }

    /**
     * @notice Get service rating
     * @param serviceAddress Service contract address
     * @return averageRating Average rating (scaled by RATING_SCALE)
     * @return ratingCount Number of ratings
     */
    function getServiceRating(
        address serviceAddress
    ) external view returns (uint256 averageRating, uint256 ratingCount) {
        ServiceListing memory listing = listings[serviceAddress];
        return (listing.averageRating, listing.ratingCount);
    }

    /**
     * @notice Get all ratings for a service
     * @param serviceAddress Service contract address
     * @return serviceRatings Array of ratings
     */
    function getServiceRatings(
        address serviceAddress
    ) external view returns (Rating[] memory serviceRatings) {
        return ratings[serviceAddress];
    }

    /**
     * @notice Get user's rating for a service
     * @param serviceAddress Service contract address
     * @param user User address
     * @return rating User's rating
     */
    function getUserRating(
        address serviceAddress,
        address user
    ) external view returns (Rating memory rating) {
        return userRatings[serviceAddress][user];
    }

    // ============ View Functions ============

    /**
     * @notice Get total number of listed services
     * @return count Total count
     */
    function getTotalServices() external view returns (uint256 count) {
        count = 0;
        for (uint256 i = 0; i < allServices.length; i++) {
            if (listings[allServices[i]].isListed) {
                count++;
            }
        }
    }

    /**
     * @notice Get services by type count
     * @param serviceType Service type
     * @return count Number of services of this type
     */
    function getServicesByTypeCount(
        Service.ServiceType serviceType
    ) external view returns (uint256 count) {
        count = 0;
        address[] memory typeServices = servicesByType[serviceType];
        for (uint256 i = 0; i < typeServices.length; i++) {
            if (listings[typeServices[i]].isListed) {
                count++;
            }
        }
    }
}

