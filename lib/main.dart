import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//Definiera färgerna som  används, dock matchar inte namnen längre då jag ändrat dem så mycket!
const Color lightPink = Color.fromARGB(169, 249, 226, 222);
const Color darkPink = Color.fromRGBO(100, 36, 46, 10);

//modell för våra objekt
class Todo {
  String id;
  String title;
  bool done;

  Todo({required this.id, required this.title, this.done = false});

  //Skapar todo från json
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      done: json['done'],
    );
  }

  //Skapa json för att kunna skicka de till apiet
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "done": done,
    };
  }
}

class TodoProvider extends ChangeNotifier {
  //api-nyckeln
  final String apiKey = "77256851-afde-4569-bd4a-49c718f22d2a";
  
  //bas-url för todos
  final String baseUrl = "https://todoapp-api.apps.k8s.gu.se/todos";
  
  final List<Todo> _todos = [];

  //Filter (kan vara "allt", "färdigt" eller "ej färdigt")
  String _filter = "allt";

  List<Todo> get todos => _todos;
  String get filter => _filter;

  //Filtrerar listan beroende på vilket filter man väljer
  List<Todo> get visibleTodos {
    if (_filter == "färdigt") return _todos.where((t) => t.done).toList();
    if (_filter == "ej färdigt") return _todos.where((t) => !t.done).toList();
    return _todos;
  }

  //Hämta todos från servern
  Future<void> fetchTodos() async {
    //Lägg till api nyckeln i url:en
    final response = await http.get(Uri.parse("$baseUrl?key=$apiKey"));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _todos.clear();
      _todos.addAll(data.map((json) => Todo.fromJson(json)).toList());
      notifyListeners();
    }
  }

  //Lägg till ny todo på server och lokalt
  Future<void> addTodo(String title) async {
    final response = await http.post(
      Uri.parse("$baseUrl?key=$apiKey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title, "done": false}),
    );
    if (response.statusCode == 200) {
      //vi uppdaterar vår lokala lista då api:et returnerar hela listan
      final List<dynamic> data = jsonDecode(response.body);
      _todos.clear();
      _todos.addAll(data.map((json) => Todo.fromJson(json)).toList());
      notifyListeners();
    }
  }

  //Markera som färdig elelr ej färdigt
  Future<void> todoDone(Todo todo, bool value) async {
    todo.done = value;
    notifyListeners();
    await http.put(
      Uri.parse("$baseUrl/${todo.id}?key=$apiKey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(todo.toJson()),
    );
  }

  //ta bort todo
  Future<void> deleteTodo(Todo todo) async {
    _todos.remove(todo);
    notifyListeners();
    await http.delete(Uri.parse("$baseUrl/${todo.id}?key=$apiKey"));
  }

  void setFilter(String newFilter) {
    _filter = newFilter;
    notifyListeners();
  }
}
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //Tar bort debug texten i högra hörnet av skärmen
      title: 'TIG333 TODO - gushanals',
      theme: ThemeData(
        scaffoldBackgroundColor: lightPink, //Bakgrund på sidorna, blir standard genom "scaffold"

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
          fillColor: WidgetStateProperty.all(Colors.white),
        ),

        textButtonTheme: TextButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            backgroundColor: darkPink,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const TodoListPage(), //Första sidan man ser
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
  //providern som har listan med todos
  final TodoProvider provider = TodoProvider();

  @override
  void initState() {
    super.initState();
    provider.fetchTodos(); //hämtar todos när sidan startar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( //Funktinerna/designen som finns i appbaren på toppen av sidan
        centerTitle: true, //Centrerar titeln, dvs TIG333
        title: const Text("TIG333 TODO - gushanals"),
        actions: [
          //meny för filtrering
          PopupMenuButton<String>(
            onSelected: (value) {
              provider.setFilter(value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "allt", child: Text("allt")),
              PopupMenuItem(value: "färdigt", child: Text("färdigt")),
              PopupMenuItem(value: "ej färdigt", child: Text("ej färdigt")),
            ],
          ),
        ],
      ),

      //AnimatedBuilder lyssnar på provider och uppdaterar UI 
      body: AnimatedBuilder(
        animation: provider,
        builder: (context, _) {
          final todos = provider.visibleTodos;
          return ListView( //ListView gör att vi kan skrolla om listan skulle bli för lång
            children: todos.map((todo) {
              return TodoItem(
                title: todo.title,
                done: todo.done,
                onChanged: (value) {
                  provider.todoDone(todo, value!);
                },
                onDelete: () {
                  provider.deleteTodo(todo);
                },
              );
            }).toList(),
          );
        },
      ),

      //Plus-knappen i hörnet, skickar en till AddTodoPage
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          final newTodo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoPage()),
          );
          if (newTodo != null) {
            provider.addTodo(newTodo);
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
  final ValueChanged<bool?> onChanged; //När checkbox ändras
  final VoidCallback onDelete; //När X-knappen trycks

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
        title: const Text("TIG333 TODO - gushanals"),
        centerTitle: true,
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