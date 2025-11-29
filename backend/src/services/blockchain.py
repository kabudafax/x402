"""Blockchain interaction service"""
from web3 import Web3
from typing import Optional, Dict, Any
import json

from src.config import settings


class BlockchainService:
    """Service for interacting with Monad blockchain"""
    
    def __init__(self):
        self.w3 = Web3(Web3.HTTPProvider(settings.MONAD_RPC_URL))
        self.chain_id = settings.MONAD_CHAIN_ID
    
    def get_balance(self, address: str, token_address: Optional[str] = None) -> int:
        """Get balance for address (native or ERC20)"""
        if token_address is None:
            # Native token balance
            return self.w3.eth.get_balance(address)
        else:
            # ERC20 token balance
            # Simplified - would need ERC20 ABI
            return 0
    
    def get_transaction(self, tx_hash: str) -> Dict[str, Any]:
        """Get transaction details"""
        tx = self.w3.eth.get_transaction(tx_hash)
        receipt = self.w3.eth.get_transaction_receipt(tx_hash)
        
        return {
            "hash": tx_hash,
            "from": tx["from"],
            "to": tx["to"],
            "value": tx["value"],
            "status": receipt["status"],
            "block_number": receipt["blockNumber"],
            "gas_used": receipt["gasUsed"]
        }
    
    def verify_payment(
        self,
        payment_id: str,
        x402_handler_address: str,
        x402_handler_abi: list
    ) -> bool:
        """Verify x402 payment was processed"""
        contract = self.w3.eth.contract(
            address=x402_handler_address,
            abi=x402_handler_abi
        )
        
        try:
            is_processed = contract.functions.isPaymentProcessed(
                Web3.to_bytes(hexstr=payment_id)
            ).call()
            return is_processed
        except Exception:
            return False

