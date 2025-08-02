import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Memory Keeper',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor:Color.fromARGB(255, 4, 8, 2)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final List<Person> people = [];
  final List<Memory> memories = [];

  void addPerson (Person person) {
    people.add(person);
    notifyListeners();
  }

  void removePerson (Person person) {
    people.remove(person);
    notifyListeners();
  }

  void addMemory (Memory memory) {
    memories.add(memory);
    notifyListeners();
  }

  void removeMemory (Memory memory) {
    memories.remove(memory);
    notifyListeners();
  }

  void update (Person newPerson, Person oldPerson) {
    int indexOfOldPerson = 0;

    for (int i = 0; i < people.length; i++) {
      if (people[i] == oldPerson) {
        indexOfOldPerson = i;
      }
    }

    people[indexOfOldPerson] = newPerson;

    for (var memory in memories) {
      if (memory.taggedPeople.contains(newPerson)) {

        for (int i = 0; i < memory.taggedPeople.length; i ++) {
          if (memory.taggedPeople[i] == oldPerson) {
            memory.taggedPeople[i] = newPerson;
          }
        }
      }
    }
    notifyListeners();    
  }

  void updateMemory (Memory oldMemory, Memory newMemory) {
    int index = 0;

    for (int i = 0; i < memories.length; i++) {
      if (memories[i] == oldMemory) {
        index = i;
      }
    }

    memories[index] = newMemory;
    notifyListeners();
  }
}

class Person {
  final String name;
  final String relationship;
  final String? notes;
  final String? imagePath;

  Person ({
    required this.name,
    required this.relationship,
    this.notes,
    this.imagePath,
  });
}

class Memory {
  final String title;
  final String description;
  final DateTime date;
  final String? imagePath;
  final List<Person> taggedPeople;

  Memory ({
    required this.title,
    required this.description,
    required this.date,
    this.imagePath,
    required this.taggedPeople,
  });
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    
    Widget page = Placeholder();

    switch (selectedIndex) {
      case 0:
        page = PeopleListPage();
        break;
      case 1:
        page = MemoryListPage();
        break;
      default:
        page = PeopleListPage();
    } 

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text('Memory Keeper', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            toolbarHeight: 35,
            bottom: PreferredSize(preferredSize: Size.fromHeight(1), 
              child: Divider(
                color: Theme.of(context).dividerColor,
                height: 1,
                thickness: 1,)
              )
          ),
          body: Row(
            children: [
              NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.person), 
                    label: Text('People'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.photo_album), 
                    label: Text('Memories'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                )
              )
            ],
          ),
        );
      }
    );
  }
}

class MemoryListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var memories = appState.memories;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: memories.isEmpty 
      ? Center(
        child: Text(
          'No memories currently added',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ) : 
      SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            for (var memory in memories)
              GestureDetector(
              onTap:() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMemoryPage(existingMemory: memory))
                );
              },
              child: MemoryCard(memory: memory)
            )
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMemoryPage()),
          );
        },
        child: Icon(Icons.add),
        ),
    );
  }
}

class MemoryCard extends StatelessWidget {

  const MemoryCard({
    required this.memory,
  });

  final Memory memory;

  String convertTaggedToString (List<Person> people) {
    String result = '';

    for (int i = 0; i < people.length; i++) {
      result = result + people[i].name + (i != people.length-1 ? ', ' : '');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {

    String dateAsString = memory.date.toString().split(' ')[0];
    String tagsAsString = convertTaggedToString(memory.taggedPeople);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MemoryProfilePage(memory: memory))
        );
      },
      child: Card(
        elevation: 3,
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: memory.imagePath != null ? Image.file(File(memory.imagePath!), fit: BoxFit.cover)
              : Icon(Icons.image, size: 40, color: Colors.grey[700]),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(memory.title, style: TextStyle(
                    fontSize:18, fontWeight: FontWeight.bold,
                    )
                  ),
                  SizedBox(height: 6,),
                  Text(
                    memory.description, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black)
                  ),
                  SizedBox(height: 6),
                  Text('Date: $dateAsString'),
                  SizedBox(height: 4),
                  Text(
                    'Tagged: $tagsAsString',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            )
          ],
        )
      ),
    );
  }
}

class AddMemoryPage extends StatefulWidget {

  final Memory? existingMemory;

  AddMemoryPage({this.existingMemory});

  @override 
  State<AddMemoryPage> createState() => _AddMemoryPageState();
}

class _AddMemoryPageState extends State<AddMemoryPage> {
  
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  DateTime date = DateTime.now();
  List<Person> selectedPeople = [];
  String? imagePath;

  @override
  void initState() {
    super.initState();

    if (widget.existingMemory != null) {
      titleController.text = widget.existingMemory!.title;
      descriptionController.text = widget.existingMemory!.description;
      date = widget.existingMemory!.date;
      selectedPeople = widget.existingMemory!.taggedPeople;
      imagePath = widget.existingMemory!.imagePath;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<MyAppState>(context);
    List<MultiSelectItem<Person>> selectablePeople = [];

    for (int i = 0; i < appState.people.length; i ++) {
      var person = appState.people[i];
      selectablePeople.add(MultiSelectItem<Person>(person, person.name));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingMemory == null ? 'Add Memory' : 'Edit Memory'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder()
                    ),
                  )
                ),
                SizedBox(width: 11,),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? chosen = await showDatePicker(
                      context: context,
                      initialDate: date, 
                      firstDate: DateTime(1900), 
                      lastDate: DateTime(2100)
                    );
                    if (chosen != null) {
                      setState(() {
                        date = chosen;
                      });
                    }
                  }, 
                  child: Text(date.toString().split(' ')[0])
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text('Tagged People', style: Theme.of(context).textTheme.titleMedium),
            MultiSelectDialogField(
              items: selectablePeople, 
              initialValue: selectedPeople,
              title: Text('Tagged People'),
              selectedColor: Theme.of(context).colorScheme.primary,
              onConfirm:(p0) {
                setState(() {
                  selectedPeople = p0;
                });
              },
              chipDisplay: MultiSelectChipDisplay(
                items: [
                  for (int i = 0; i < selectedPeople.length; i++)
                    MultiSelectItem<Person>(selectedPeople[i], selectedPeople[i].name)
                ],
                onTap: (person) {
                  setState(() {
                    selectedPeople.remove(person);
                  });
                },
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: Column(
                children: [
                  imagePath != null ?
                  Image.file(File(imagePath!), height: 180, width: 180, fit: BoxFit.cover)
                  : Container(
                    height: 180,
                    width: 180,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 60, color: Colors.grey[700])
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      String? path = await pickImageFromGallery();
                      if (path != null) {
                        setState(() {
                          imagePath = path;
                        });
                      }
                    },
                    child: Text(imagePath == null ? 'Add Image' : 'Change Image'),
                  ),
                  if (imagePath != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          imagePath = null;
                        });
                      },
                      child: Text('Remove Image'),
                    )
                ],
              )
            ),
            SizedBox(height:40),
             ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                minimumSize: Size(double.infinity, 60)
              ),
              onPressed: () {
                var title = titleController.text.trim();
                var description = descriptionController.text.trim();

                if (title.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in the required fields.'))
                  );
                  return;
                }
                var memory = Memory(
                  title: title, 
                  description: description, 
                  date: date,
                  taggedPeople: selectedPeople,
                  imagePath: imagePath
                );
                
                var appState = Provider.of<MyAppState>(context, listen: false);

                if (widget.existingMemory == null) {
                  appState.addMemory(memory);
                } else {
                  appState.updateMemory(widget.existingMemory!, memory);
                }

                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                )
              ),
            )
          ],
        )
      )
    );
  }
}

class MemoryProfilePage extends StatelessWidget {
  final Memory memory;

  MemoryProfilePage ({required this.memory});

  String convertTaggedToString (List<Person> people) {
    String result = '';

    for (int i = 0; i < people.length; i++) {
      result = result + people[i].name + (i != people.length-1 ? ', ' : '');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    String dateAsString = memory.date.toString().split(' ')[0];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          memory.title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddMemoryPage(existingMemory: memory,))
              ). then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Memory updated!'))
                );
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            memory.imagePath != null ?
            Image.file(
              File(memory.imagePath!),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover
            ) 
            : Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Icon(Icons.image, size: 60, color: Colors.grey[700])
            ),
            SizedBox(height: 16),
            Text('Description:', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height:4),
            Text(memory.description),
            SizedBox(height: 16),
            Text('Date:', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 4),
            Text(dateAsString),
            SizedBox(height:16),
            Text('Tagged People:', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 4),
            Text(convertTaggedToString(memory.taggedPeople)),
          ],
        )
      )
    );
  }

}

class PeopleListPage extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();
    var people = appState.people;

  
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: people.isEmpty 
      ? Center(
        child: Text(
          'No people currently added',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ) :
      GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 5/4,
        children: [
          for (var person in people)
            GestureDetector(
              onTap:() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PersonProfilePage(person: person))
                );
              },
              child: PersonCard(person: person)
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPersonPage()),
          );
        },
        child: Icon(Icons.add),
        ),
    );
  }
}

class PersonCard extends StatelessWidget {
  const PersonCard({
    required this.person,
  });

  final Person person;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 3),
          CircleAvatar(
            radius: 30,
            backgroundImage: person.imagePath != null ? FileImage(File(person.imagePath!)) : null,
            child: person.imagePath == null ? Text(person.name[0]) :  null,
          ),
          SizedBox(
            height: 8
          ),
          Flexible(
            child: Text(
              person.name, style: TextStyle(fontWeight: FontWeight.bold)
            ),
          ),
          Flexible(
            child: Text(
              person.relationship, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)
            ),
          ),
        ],
      )
    );
  }
}

class AddPersonPage extends StatefulWidget {

  final Person? existingPerson;

  AddPersonPage({
    this.existingPerson
  });
  
  @override
  State<AddPersonPage> createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  
  var nameController = TextEditingController();
  var relationshipController = TextEditingController();
  var notesController = TextEditingController();
  String? imagePath;

  @override
  void initState() {
    super.initState();

    if (widget.existingPerson != null) {
      nameController.text = widget.existingPerson!.name;
      relationshipController.text = widget.existingPerson!.relationship;

      if (widget.existingPerson!.imagePath != null) {
        imagePath = widget.existingPerson!.imagePath;
      }
      
      if (widget.existingPerson!.notes == null) {
        notesController.text = "";
      } else {
        notesController.text = widget.existingPerson!.notes!;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    relationshipController.dispose();
    notesController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(
        widget.existingPerson == null ? 'Add Person' : 'Edit Person',
        style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer,)),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            SizedBox(height: 25),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: imagePath != null ? FileImage(File(imagePath!)) : null,
                    child: imagePath == null ? Icon(Icons.person, size: 60) : null
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      String? path = await pickImageFromGallery();

                      if (path!= null) {
                        setState(() {
                          imagePath = path;
                        });
                      }
                    },
                    child: Text(imagePath == null ? 'Add Image' : 'Change Image'),
                  ),
                  if (imagePath != null) 
                    TextButton(
                      onPressed: () {
                        setState(() {
                          imagePath = null;
                        });
                      },
                      child: Text('Remove Image')
                    )
                ],
              )
            ),
            SizedBox(height: 50,),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: relationshipController,
                    decoration: InputDecoration(
                      labelText: 'Relationship',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            TextField(
              maxLines: 4,
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                minimumSize: Size(double.infinity, 60)
              ),
              onPressed: () {
                var name = nameController.text.trim();
                var relationship = relationshipController.text.trim();
                var notes = notesController.text.trim();

                if (name.isEmpty || relationship.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in the required fields.'))
                  );
                  return;
                }
                var person = Person(
                  name: name, 
                  relationship: relationship, 
                  notes: notes.isEmpty ? null : notes,
                  imagePath: imagePath
                );
                
                var appState = Provider.of<MyAppState>(context, listen: false);

                if (widget.existingPerson == null) {
                  appState.addPerson(person);
                } else {
                  appState.update(person, widget.existingPerson!);
                }

                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                )
              ),
            )
          ],
        )
      )
    );
  }
}

class PersonProfilePage extends StatelessWidget {
  
  final Person person;

  PersonProfilePage ({required this.person});

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<MyAppState>(context);
    List<Memory> taggedMemories = [];

    for (int i = 0; i < appState.memories.length; i ++) {
      if (appState.memories[i].taggedPeople.contains(person)) {
        taggedMemories.add(appState.memories[i]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(person.name, 
          style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer,)),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPersonPage(existingPerson: person))
              ). then((_) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Person updated!'))
                );
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 25),
            CircleAvatar(
              radius: 60,
              backgroundImage: person.imagePath != null ? FileImage(File(person.imagePath!)) : null,
              child: person.imagePath == null ? Icon(Icons.person, size: 40) : null
            ),
            SizedBox(height: 20),
            Text(person.name, style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 10),
            Text(person.relationship, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            SizedBox(height: 17),
            if (!(person.notes == null || person.notes!.isEmpty)) 
              Text(person.notes!, style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 30),
            Align(
              alignment: taggedMemories.isEmpty ? Alignment.center : Alignment.centerLeft,
              child: Text(
                taggedMemories.isEmpty ?
                'No memories with ${person.name}' :
                'Memories with ${person.name}:', style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(height: 10),
            Column(
              children: [
                for (var memory in taggedMemories)
                  MemoryCard(memory: memory)
              ],
            )
          ],
        )
      )
    );
  }
}

Future<String?> pickImageFromGallery() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  return pickedFile?.path;
}

Future<String?> pickImageFromCamera() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);
  return pickedFile?.path;
}

