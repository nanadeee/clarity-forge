# Clarity Forge

A modular on-chain Clarity contract factory system built on Stacks (STX) using Clarity v2. This contract enables admin-controlled registration of Clarity module templates and deployment of contract instances from registered modules with full audit trail and event logging.

## Overview

Clarity Forge creates a decentralized infrastructure for composable smart contract deployments where admins register module templates with code hash references, users deploy new contract instances from active modules, and the system maintains a complete provenance record of all deployments.

## Features

### Module Management
- Admin registers modules with code hash references
- Maximum 40-byte module names for efficiency
- 64-byte code hash for SHA-256 references
- Module activation/deactivation controls
- Prevents deployment from inactive modules

### Contract Deployment
- Deploy new contract instances from registered modules
- Track deployer, module reference, and deployment metadata
- Auto-incrementing contract IDs for unique identification
- Deployment events logged on-chain for transparency
- Labels for contract organization (up to 40 bytes)

### Access Control
- Admin-only module registration and management
- Any user can deploy contracts from active modules
- tx-sender verification on all admin functions
- Prevents unauthorized module modifications

### State Tracking
- Maintains module registry with active status
- Tracks deployed contracts with full provenance
- Global module and contract counters
- Non-fungible deployment records

## Technical Specifications

### Storage
| Variable | Type | Purpose |
|----------|------|---------|
| `modules` | map | Module registry with active status |
| `deployed-contracts` | map | Deployment records with metadata |
| `module-counter` | data var | Auto-incrementing module ID |
| `contract-counter` | data var | Auto-incrementing contract ID |

### Data Structures

**Module Record:**
