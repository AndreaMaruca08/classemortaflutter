enum EventType {
  ASSENZA,
  RITARDO, // Permesso di entrata
  USCITA_ANTICIPATA, // Permesso di uscita
  unknown,
}

EventType eventTypeFromString(String eventString) {
  if (eventString.toLowerCase().contains("assenza")) {
    return EventType.ASSENZA;
  } else if (eventString.toLowerCase().contains("permesso di entrare")) {
    return EventType.RITARDO;
  } else if (eventString.toLowerCase().contains("permesso di uscire")) {
    return EventType.USCITA_ANTICIPATA;
  }
  return EventType.unknown;
}
