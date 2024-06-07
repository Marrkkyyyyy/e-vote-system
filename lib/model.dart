class VoteList {
  VoteList({
    required this.votersID,
    required this.candidateID,
    required this.positionID,
    required this.isChecked,
  });

  String votersID;
  String candidateID;
  String positionID;
  bool isChecked;

  factory VoteList.fromJson(Map<String, dynamic> json) => VoteList(
        votersID: json["votersID"],
        candidateID: json["candidateID"],
        positionID: json["positionID"],
        isChecked: json["isChecked"],
      );

  Map<String, dynamic> toJson() => {
        "votersID": votersID,
        "candidateID": candidateID,
        "positionID": positionID,
        "isChecked": isChecked,
      };
  @override
  String toString() {
    return '{ ${this.votersID}, ${this.candidateID}, ${this.positionID}, ${this.isChecked} }';
  }
}
