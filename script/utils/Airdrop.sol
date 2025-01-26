// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import "forge-std/Vm.sol";

function readAirdropData(Vm vm, string memory filePath)
    returns (address[] memory recipients, uint256[] memory amounts)
{
    string[] memory lines = readFileLines(vm, filePath);

    recipients = new address[](lines.length);
    amounts = new uint256[](lines.length);

    // Parse CSV data
    for (uint256 i; i < lines.length; i++) {
        string memory s = lines[i];
        (string memory addressStr, string memory amountStr) = splitLine(s);

        recipients[i] = vm.parseAddress(addressStr);
        uint256 amount = vm.parseUint(amountStr) * 1 ether;
        amounts[i] = amount;
    }
}

function readFileLines(Vm vm, string memory filePath) returns (string[] memory lines) {
    // First count the lines
    uint256 fileLineCount;

    string memory line = vm.readLine(filePath);
    while (bytes(line).length > 0) {
        fileLineCount++;
        line = vm.readLine(filePath);
    }

    if (fileLineCount == 0) {
        return new string[](0); // Empty file
    }

    // Reset file pointer by reading file again
    vm.closeFile(filePath);

    // Now read the actual lines
    lines = new string[](fileLineCount);
    for (uint256 i; i < fileLineCount; i++) {
        lines[i] = vm.readLine(filePath);
    }

    vm.closeFile(filePath);
}

// Helper function to split a line into address and amount
function splitLine(string memory line) pure returns (string memory, string memory) {
    bytes memory lineBytes = bytes(line);
    uint256 commaIndex;

    // Find the comma
    for (uint256 i = 0; i < lineBytes.length; i++) {
        if (lineBytes[i] == bytes1(",")) {
            commaIndex = i;
            break;
        }
    }

    require(commaIndex > 0, "Invalid line format");

    // Split the line
    bytes memory addrBytes = new bytes(commaIndex);
    bytes memory amountBytes = new bytes(lineBytes.length - commaIndex - 1);

    for (uint256 i = 0; i < commaIndex; i++) {
        addrBytes[i] = lineBytes[i];
    }

    for (uint256 i = 0; i < amountBytes.length; i++) {
        amountBytes[i] = lineBytes[i + commaIndex + 1];
    }

    return (string(addrBytes), string(amountBytes));
}
