import 'pipeline.dart';

/// Things to look at or ask on a viewing. Ticked ones are problems.
typedef CheckItem = ({String id, String label, String ask});

const _both = <CheckItem>[
  (
    id: 'damp',
    label: 'Damp or mould',
    ask: 'Black spots, musty smell, peeling paper, wet patches near windows and ceilings.',
  ),
  (
    id: 'heating',
    label: 'Heating and hot water',
    ask: 'Turn on a tap and a radiator. What fuel, and how old is the boiler?',
  ),
  (
    id: 'epc',
    label: 'Energy rating poor (E or worse)',
    ask: 'Ask for the EPC. Bills run high in E, F and G homes.',
  ),
  (
    id: 'windows',
    label: 'Windows and doors',
    ask: 'Do they close, lock and seal? Any draughts or cracked glass?',
  ),
  (id: 'electrics', label: 'Electrics', ask: 'Sockets enough, scorch marks, an old fuse box.'),
  (
    id: 'signal',
    label: 'Phone signal or broadband weak',
    ask: 'Check your own phone. Ask the speed, or check the Ofcom checker.',
  ),
  (id: 'noise', label: 'Noise', ask: 'Visit at a busy time of day too: road, neighbours, pubs, trains.'),
  (
    id: 'flood',
    label: 'Flood risk',
    ask: 'Ask if it has flooded. Check the long-term flood risk for the postcode.',
  ),
  (id: 'parking', label: 'Parking', ask: 'Where do you park, and is a permit needed?'),
];

const _rent = <CheckItem>[
  (
    id: 'alarms',
    label: 'No smoke or carbon monoxide alarms',
    ask: 'The landlord must provide them. Ask when they were tested.',
  ),
  (
    id: 'gas',
    label: 'No gas safety certificate',
    ask: 'Must be given before you move in, and renewed every year.',
  ),
  (id: 'eicr', label: 'No electrical safety report', ask: 'Ask to see a report less than five years old.'),
  (
    id: 'deposit',
    label: 'Deposit not in a protection scheme',
    ask: 'It must be protected within 30 days. Ask which scheme.',
  ),
  (
    id: 'fees',
    label: 'Fees you cannot be charged',
    ask: 'Only rent, a deposit, a holding deposit and a few default charges are allowed.',
  ),
  (id: 'bills', label: 'Bills unclear', ask: 'What is included? Council tax band and typical monthly bills.'),
  (
    id: 'landlord',
    label: 'Landlord or agent evasive',
    ask: 'Who is the landlord? Are they registered, and do they own the home?',
  ),
];

const _buy = <CheckItem>[
  (
    id: 'roof',
    label: 'Roof, gutters or chimney',
    ask: 'Missing slates, sagging lines, stained ceilings below.',
  ),
  (id: 'cracks', label: 'Cracks in walls', ask: 'Wide or stepped cracks, sticking doors: possible movement.'),
  (
    id: 'lease',
    label: 'Leasehold terms',
    ask: 'Years left, ground rent, service charge and any planned works.',
  ),
  (id: 'council', label: 'Council tax band high', ask: 'Check the band, and what neighbours pay.'),
  (
    id: 'planning',
    label: 'Planning or building works nearby',
    ask: 'Search planning applications for the street.',
  ),
  (
    id: 'extension',
    label: 'Extensions without paperwork',
    ask: 'Ask for building regulations sign-off and planning permission.',
  ),
];

/// The list for a home to rent or buy.
List<CheckItem> viewingChecklist(PropertyKind kind) => [
  ..._both,
  ...(kind == PropertyKind.buy ? _buy : _rent),
];

/// A note to keep with the property: what was wrong at the viewing.
String viewingNote(String date, List<CheckItem> found) => found.isEmpty
    ? 'Viewing $date: nothing wrong spotted.'
    : 'Viewing $date, problems: ${found.map((i) => i.label.toLowerCase()).join('; ')}.';
