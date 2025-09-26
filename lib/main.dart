import 'package:flutter/material.dart'; 

//Utkast 2, nu är appen funktionell, men sparar ej alla todos efter man stängt appen

void main() {
  runApp(const MyApp()); //Startar appen med MyApp
}

//Definiera färgerna vi vill använda, så det bilr lättare att använda dem
//Har ändrat färgerna en heldel, så namnen passar inte färgen förtillfället
const Color lightPink = Color.fromARGB(169, 239, 231, 213); 
const Color darkPink = Color.fromRGBO(100, 36, 46, 10);  

//Klass för en Todo, dvs modell för våra objekt
class Todo {
  String title;
  bool done;
  Todo({required this.title, this.done = false});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'TIG333 TODO',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(169, 239, 231, 213), //Bakgrund på sidorna, blir standard genom "scaffold"
        
        //Färgerna på toppbaren/appbaren
        appBarTheme: const AppBarTheme(
          backgroundColor: darkPink,
          foregroundColor: Colors.white, //Vit text i appbaren
        ),

        //Färger/tema för +knappen i hörnet
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: darkPink,
          foregroundColor: Colors.white,
        ),

        //Tema för alla checkboxar
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(const Color.fromARGB(255, 255, 255, 255)),
        ),

        //Tema för text knappar, dvs "lägg till" i detta fallet
        textButtonTheme: TextButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            backgroundColor: darkPink,
            foregroundColor: Colors.white,
          )
        ),
      ),
      home: const TodoListPage(), //Första sidan mans er
    );
  }
}

//Förstasidan, dvs listan med todos

class TodoListPage extends StatefulWidget { //Statefulwidget för att kunna uppdatera sidan
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  // Vår lista med todos
  List<Todo> todos = [
    
  ];

  // Filter (kan vara "allt", "färdigt" eller "ej färdigt")
  String filter = "allt";

  @override
  Widget build(BuildContext context) {
    //Filterar listan beroende på vilket filter man väljer
    List<Todo> visibleTodos = todos.where((todo) {
      if (filter == "färdigt") return todo.done;
      if (filter == "ej färdigt") return !todo.done;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar( //Funktinerna/designen som finns i appbaren på toppen av sidan
        centerTitle: true, //Centrerar titeln, dvs TIG333
        title: const Text("TIG333 TODO"),
        actions: [

          //meny för filtrering
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                filter = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "allt", child: Text("allt")),
              PopupMenuItem(value: "färdigt", child: Text("färdigt")),
              PopupMenuItem(value: "ej färdigt", child: Text("ej färdigt")),
            ],
          )
        ],
      ),
      body: ListView( //ListView gör att vi kan skrolla om listan skulle bli för lång
        children: visibleTodos.map((todo) {
          return TodoItem(
            title: todo.title,
            done: todo.done,
            onChanged: (value) {
              setState(() {
                todo.done = value!;
              });
            },
            onDelete: () {
              setState(() {
                todos.remove(todo);
              });
            },
          );
        }).toList(),
      ),

      //Plus-knappen i hörnet, samt att man blir skickad till ADD-sidan om man trycker på den 
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          final newTodo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoPage()),
          );
          if (newTodo != null) {
            setState(() {
              todos.add(Todo(title: newTodo));
            });
          }
        },
        child: const Icon(Icons.add), //Plusikonen
      ),
    );
  }
}

//Widget för varje Todo-rad 
class TodoItem extends StatelessWidget {
  final String title; //Texten på todo
  final bool done; //Om todon är färdig eller inte
  final ValueChanged<bool?> onChanged; //Callback när checkbox ändras
  final VoidCallback onDelete; //Callback när X-knappen trycks

  const TodoItem({
    super.key, 
    required this.title, 
    required this.done,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, //Gör todo rutan vit
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), //Ger rutan rundade hörn
      ),
      elevation: 3, //Ger liten skugga under Card
      child: ListTile( //Standard widget för rader med ikon och text
        leading: Checkbox(
          value: done, //Om todon är färdig eller inte 
          activeColor: darkPink, //Checkbox är mörkrosa
          onChanged: onChanged,
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : null, //Stryker todon om den är färdig
            color: Colors.black87,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.black), //"x" knappen till höger om todon
          onPressed: onDelete,
        ),
      ),
    );
  }
}


//Andrasidan där man lägger till todo
//Ändrad till StatefulWidget
class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController controller = TextEditingController(); //Håller koll på vad som skrivs i textfältet

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( //Innuti finns funktioner som ska finnas i appbaren

        //Pil ikon för att gå tillbaka till todo listan/sidan
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), //Gå tillbaka när man klickat på knappen
        ),

        //Titeln i toppbaren/appbaren
        title: const Text("TIG333 TODO"),
        centerTitle: true
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), //Padding ger luft mellan innehållet 
        child: Column( //Staplar widgets vertikalt
          crossAxisAlignment: CrossAxisAlignment.start, //Vänsterjusterar innehållet
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(), //Ramen
                hintText: "Vad vill du lägga till?", //Texten i ramen innan den används
                filled: true,
                fillColor: Colors.white, //Vit bakgrund i ramen
              ),
            ),
            const SizedBox(height: 16), //Mellanrum
            Center(
              child: TextButton.icon( //Vad som händer när man klickar på ADD knappen, samt dens färg
                onPressed: () {
                  if (controller.text.isNotEmpty) {

                        Navigator.pop(context, controller.text); //skicka tillbaka texten

                    }
                  },
                icon: const Icon(Icons.add, color: Colors.white), //+ ikonen
                label: const Text("LÄGG TILL"), //Texten i rutan
              ),
            )
          ],
        ),
      ),
    );
  }
}
