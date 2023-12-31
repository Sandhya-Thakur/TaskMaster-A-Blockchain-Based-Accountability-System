// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

contract AccountabilityContract {
    struct Task {
        string description;
        bool isCompleted;
    }

    Task[] public tasks;
    uint256 public deposit;
    address public owner;

    event TaskCreated(uint256 taskId, string description);
    event TaskCompleted(uint256 taskId);
    event DepositWithdrawn(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createTask(string memory _description) public onlyOwner {
        require(deposit>0, "you dont have deposite");
        tasks.push(Task(_description, false));
        emit TaskCreated(tasks.length - 1, _description);
    }

    function depositFunds() public payable onlyOwner {
        require(msg.value > 0, "Deposit amount must be greater than 0.");
        deposit += msg.value;
    }


    function allTaskCompleted() private view returns (bool) {
        for (uint256 i = 0; i < tasks.length; i++) {
            if (!tasks[i].isCompleted) {
                return false;
            }
        }
        return true;
    }

    function clearTask() private {
        delete tasks;
    }

    function completeTask(uint256 _taskId) public onlyOwner {
        require(_taskId < tasks.length, "Invalid task id.");
        require(!tasks[_taskId].isCompleted, "Task is already completed.");

        tasks[_taskId].isCompleted = true;
        emit TaskCompleted(_taskId);

        if (allTaskCompleted()) {
            uint256 amount = deposit;
            payable(owner).transfer(amount);
            deposit = 0;
            emit DepositWithdrawn(amount);
            clearTask();
        }
    }

    function getTaskCount() public view returns (uint256) {
        return tasks.length;
    }

    function getDeposit() public view returns (uint256) {
        return deposit;
    }

    function getTasks() public view returns (Task[] memory) {
        return tasks;
    }
}