// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Market} from "../src/Market.sol";
import {Service} from "../src/Service.sol";
import {X402PaymentHandler} from "../src/x402/X402PaymentHandler.sol";
import {MockERC20} from "./mocks/MockERC20.sol";

contract MarketTest is Test {
    Market public market;
    X402PaymentHandler public x402Handler;
    Service public service1;
    Service public service2;
    MockERC20 public usdc;
    address public provider1;
    address public provider2;
    address public user;

    function setUp() public {
        provider1 = address(0x1);
        provider2 = address(0x2);
        user = address(0x3);

        // Deploy mock USDC
        usdc = new MockERC20();
        usdc.mint(provider1, 1000000 * 10**6);
        usdc.mint(provider2, 1000000 * 10**6);

        // Deploy x402 payment handler
        x402Handler = new X402PaymentHandler();

        // Deploy market
        market = new Market(address(this));

        // Deploy services
        vm.startPrank(provider1);
        service1 = new Service(
            address(x402Handler),
            "Strategy Service 1",
            "A strategy service",
            Service.ServiceType.STRATEGY,
            100 * 10**6,
            address(usdc),
            Service.PricingModel.PAY_PER_USE,
            provider1
        );
        vm.stopPrank();

        vm.startPrank(provider2);
        service2 = new Service(
            address(x402Handler),
            "Risk Control Service",
            "A risk control service",
            Service.ServiceType.RISK_CONTROL,
            200 * 10**6,
            address(usdc),
            Service.PricingModel.PAY_PER_USE,
            provider2
        );
        vm.stopPrank();
    }

    function testListService() public {
        vm.startPrank(provider1);
        market.listService(address(service1));
        vm.stopPrank();

        Market.ServiceListing memory listing = market.getServiceListing(address(service1));
        
        assertTrue(listing.isListed);
        assertEq(listing.serviceAddress, address(service1));
        assertEq(listing.name, "Strategy Service 1");
        assertEq(uint256(listing.serviceType), uint256(Service.ServiceType.STRATEGY));
        assertEq(listing.provider, provider1);
    }

    function testListServiceNotProvider() public {
        vm.startPrank(user);
        vm.expectRevert("Market: Not service provider");
        market.listService(address(service1));
        vm.stopPrank();
    }

    function testDelistService() public {
        // List first
        vm.startPrank(provider1);
        market.listService(address(service1));
        
        // Delist
        market.delistService(address(service1));
        vm.stopPrank();

        Market.ServiceListing memory listing = market.getServiceListing(address(service1));
        assertFalse(listing.isListed);
    }

    function testUpdateListing() public {
        vm.startPrank(provider1);
        market.listService(address(service1));
        
        // Update service price
        service1.updateService("Updated Name", "Updated Desc", 150 * 10**6);
        
        // Update listing
        market.updateListing(address(service1));
        vm.stopPrank();

        Market.ServiceListing memory listing = market.getServiceListing(address(service1));
        assertEq(listing.name, "Updated Name");
        assertEq(listing.price, 150 * 10**6);
    }

    function testGetServicesByType() public {
        // List services
        vm.startPrank(provider1);
        market.listService(address(service1));
        vm.stopPrank();

        vm.startPrank(provider2);
        market.listService(address(service2));
        vm.stopPrank();

        // Get strategy services
        (address[] memory services, uint256 total) = market.getServicesByType(
            Service.ServiceType.STRATEGY,
            0,
            10
        );

        assertEq(total, 1);
        assertEq(services.length, 1);
        assertEq(services[0], address(service1));
    }

    function testRateService() public {
        vm.startPrank(provider1);
        market.listService(address(service1));
        vm.stopPrank();

        // Record usage first
        market.recordServiceUsage(address(service1), user);

        // Rate service
        vm.startPrank(user);
        market.rateService(address(service1), 5, "Great service!");
        vm.stopPrank();

        (uint256 avgRating, uint256 ratingCount) = market.getServiceRating(address(service1));
        assertEq(ratingCount, 1);
        assertEq(avgRating, 5 * 100); // Scaled by 100
    }

    function testRateServiceWithoutUsage() public {
        vm.startPrank(provider1);
        market.listService(address(service1));
        vm.stopPrank();

        vm.startPrank(user);
        vm.expectRevert("Market: Must use service before rating");
        market.rateService(address(service1), 5, "");
        vm.stopPrank();
    }

    function testRateServiceInvalidRating() public {
        vm.startPrank(provider1);
        market.listService(address(service1));
        vm.stopPrank();

        market.recordServiceUsage(address(service1), user);

        vm.startPrank(user);
        vm.expectRevert("Market: Invalid rating");
        market.rateService(address(service1), 6, "");
        vm.stopPrank();
    }

    function testUpdateRating() public {
        vm.startPrank(provider1);
        market.listService(address(service1));
        vm.stopPrank();

        market.recordServiceUsage(address(service1), user);

        // First rating
        vm.startPrank(user);
        market.rateService(address(service1), 3, "OK");
        
        // Update rating
        market.rateService(address(service1), 5, "Actually great!");
        vm.stopPrank();

        (uint256 avgRating, uint256 ratingCount) = market.getServiceRating(address(service1));
        assertEq(ratingCount, 1); // Still 1 rating
        assertEq(avgRating, 5 * 100); // Updated to 5
    }

    function testRecordServiceUsage() public {
        vm.startPrank(provider1);
        market.listService(address(service1));
        vm.stopPrank();

        market.recordServiceUsage(address(service1), user);
        
        assertEq(market.serviceUsage(address(service1), user), 1);

        Market.ServiceListing memory listing = market.getServiceListing(address(service1));
        assertEq(listing.callCount, 1);
    }

    function testGetAllServices() public {
        vm.startPrank(provider1);
        market.listService(address(service1));
        vm.stopPrank();

        vm.startPrank(provider2);
        market.listService(address(service2));
        vm.stopPrank();

        (address[] memory services, uint256 total) = market.getAllServices(0, 10);
        
        assertEq(total, 2);
        assertEq(services.length, 2);
    }
}

