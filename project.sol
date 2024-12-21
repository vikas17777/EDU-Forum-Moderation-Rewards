// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForumModerationRewards {
    struct ModerationTask {
        string description;
        address creator;
        uint256 reward;
        bool isCompleted;
        address[] moderators;
    }

    ModerationTask[] public tasks;
    mapping(address => uint256) public moderatorTokens;

    event TaskCreated(
        uint256 taskId,
        string description,
        address creator,
        uint256 reward
    );

    event ModeratorAdded(
        uint256 taskId,
        address moderator
    );

    event TokensDistributed(
        uint256 taskId,
        uint256 reward
    );

    event TokensClaimed(
        address moderator,
        uint256 amount
    );

    // Create a new moderation task
    function createTask(
        string memory description,
        uint256 reward
    ) public payable {
        require(msg.value == reward, "Reward amount must be funded.");

        address[] memory moderators;
        tasks.push(ModerationTask({
            description: description,
            creator: msg.sender,
            reward: reward,
            isCompleted: false,
            moderators: moderators
        }));

        emit TaskCreated(tasks.length - 1, description, msg.sender, reward);
    }

    // Add a moderator to a task
    function addModerator(uint256 taskId) public {
        ModerationTask storage task = tasks[taskId];
        require(!task.isCompleted, "Task is already completed.");

        task.moderators.push(msg.sender);

        emit ModeratorAdded(taskId, msg.sender);
    }

    // Mark task as completed and distribute rewards
    function completeTask(uint256 taskId) public {
        ModerationTask storage task = tasks[taskId];
        require(msg.sender == task.creator, "Only the creator can mark this task as completed.");
        require(!task.isCompleted, "Task is already completed.");
        require(task.moderators.length > 0, "No moderators to reward.");

        task.isCompleted = true;
        uint256 rewardPerModerator = task.reward / task.moderators.length;

        for (uint256 i = 0; i < task.moderators.length; i++) {
            moderatorTokens[task.moderators[i]] += rewardPerModerator;
        }

        emit TokensDistributed(taskId, task.reward);
    }

    // Claim tokens
    function claimTokens() public {
        uint256 amount = moderatorTokens[msg.sender];
        require(amount > 0, "No tokens to claim.");

        moderatorTokens[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit TokensClaimed(msg.sender, amount);
    }

    // Get all tasks
    function getAllTasks() public view returns (ModerationTask[] memory) {
        return tasks;
    }
}