/// Room type for Home listings
enum RoomType {
  entirePlace('Entire place', 'Guests have the whole property to themselves'),
  privateRoom('Private room', 'Guests have their own room, share some spaces'),
  sharedRoom('Shared room', 'Guests share the room with others');

  final String label;
  final String description;
  const RoomType(this.label, this.description);
}
