// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2 <0.9.0;
// pragma experimental ABIEncoderV2;

contract AudioEyes {
  address public owner = 0x501456fbcaFf4553267b203322c6E5C6bf689817;

  uint currentSpamFee = 10**17;

  uint currentTx = 0;

  uint queueHeight = 0;

  uint tip_savings = 0;

  uint tax = 10;

  uint maxBonus = 10;

  uint totalTipped = 0;

  struct Transcription {
  	string doc;
  	string trans;
  	address payable owner;
  	uint guananteedTip;
  }

  struct Document {
  	uint txNumber;
  	uint queueIndex;
  	uint queueHeight;
  	uint spamFee;
  	uint guananteedTip;
  	string addr;
  	address payable owner;
  	bool active;
  }

  mapping (string => Transcription) transcriptions;
  mapping (string => Document) docs;
  mapping (address => uint) tipTotals;
  Document[] queue;

  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }

  function requestTranscription(string memory doc) public payable {
  	require(msg.value >= currentSpamFee, "Transaction value must match or exceed spamFee");
  	Document memory newDoc = Document(currentTx, queue.length, queueHeight+1, currentSpamFee, msg.value-currentSpamFee, doc, payable(msg.sender), true);

  	docs[doc].txNumber = currentTx;
    docs[doc].queueIndex = queue.length;
    docs[doc].queueHeight = queueHeight+1;
    docs[doc].spamFee = currentSpamFee;
    docs[doc].guananteedTip = msg.value-currentSpamFee;
    docs[doc].addr = doc;
    docs[doc].owner = payable(msg.sender);
    docs[doc].active = true;

    queue.push(newDoc);

  	queueHeight += 1;
  }

  function changeSpamFee(uint price) public restricted {
  	currentSpamFee = price;
  }

  function getSpamFee() public view returns(uint fee) {
  	fee = currentSpamFee;
  }

  function submitTranscription (string memory docAddr, string memory transcription) public {
    // todo prevent duplicate calls draining smart contract
  	Document memory doc = docs[docAddr];

  	// remove stale orders from queue
  	for (uint i = 0; i < queue.length; i++) {
  		Document memory current = queue[i];
  		if ((queueHeight - current.txNumber) >= current.queueHeight*3) {
  			uint index = current.queueIndex;
  			uint lastIndex = queue.length-1;
  			queue[lastIndex].queueIndex = index;
  			queue[index] = queue[lastIndex];
  			queue.pop();
  			docs[current.addr].active = false;

        queueHeight -= 1;
  		}
  	}

  	// return spam fee
    (bool success, ) = msg.sender.call{value: doc.spamFee}("");
    require(success, "Transfer failed.");

  	// remove doc from queue
  	uint Qindex = doc.queueIndex;
  	uint QlastIndex = queue.length-1;
  	queue[QlastIndex].queueIndex = Qindex;
  	queue[Qindex] = queue[QlastIndex];
  	queue.pop();
  	docs[docAddr].active = false;

  	queueHeight -= 1;
  	currentTx += 1;

  	// Transcription memory newTrans = Transcription(docAddr, transcription, payable(msg.sender), doc.guananteedTip);
  	// transcriptions[docAddr] = newTrans;
    transcriptions[docAddr].doc = docAddr;
    transcriptions[docAddr].trans = transcription;
    transcriptions[docAddr].owner = payable(msg.sender);
    transcriptions[docAddr].guananteedTip = doc.guananteedTip;
  }

  function getTranscription (string memory docAddr) public view returns(string memory trans) {
  	trans = transcriptions[docAddr].trans;
  }

  function tip (string memory docAddr) public payable {
  	address payable target = transcriptions[docAddr].owner;

  	uint gross_tip = msg.value;
  	uint saved = gross_tip * tax / 100;
  	tip_savings += saved;
  	uint base_tip = gross_tip - saved;
  	uint bonus = maxBonus * tipTotals[target]**2 / totalTipped**2;
  	uint finished_tip = base_tip + bonus;

  	target.transfer(finished_tip);

  	totalTipped += finished_tip;
  	tipTotals[target] += finished_tip;
  }

}