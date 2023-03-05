import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lab_activity/recipe.dart';
import 'package:lab_activity/recipeRepository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = "";

  //Login user
  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
      });
    }
  }

  //Register user
  Future<void> _register() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _emailController.clear();
        _passwordController.clear();
      });

      //return alert dialog box
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Message"),
            content: const Text("Registration Successful"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message!;
      });
    }
  }

  //show dialog box

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login | Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
                hintText: 'Enter valid email',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              obscureText: true,
              controller: _passwordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                hintText: 'Enter secure password',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('User Login'),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('User Register'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

//Home page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _navigateToRecipePage(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const RecipePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Home Page'),
            const SizedBox(
              height: 10,
            ),
            const Text('Click this to view recipes'),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  _navigateToRecipePage(context);
                },
                child: const Text('View Recipes')),
            ElevatedButton(
                onPressed: () {
                  //logout user
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                },
                child: const Text('Logout'))
          ],
        ),
      ),
    );
  }
}

//Manage receipes page
class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  @override
  Widget build(BuildContext context) {
    final RecipeRepository recipeRepository = RecipeRepository();

    //delete function
    void _DeleteRecipe(String id) {
      setState(() {
        recipeRepository.deleteRecipe(id);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Recipe>>(
                future: recipeRepository.getAllRecipes(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List<Recipe>? recipes = snapshot.data;
                    return ListView.builder(
                      itemCount: recipes!.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            title: Text(recipe.title.toString()),
                            subtitle: Text(recipe.description.toString()),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OneRecipe(recipe),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.visibility,
                                        color: Colors.yellow)),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UpdateRecipe(recipe),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _DeleteRecipe(recipe.id.toString());
                                  },
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddRecipePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

//Recipe add Page
class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  List<String> ingredients = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  final RecipeRepository _recipeRepository = RecipeRepository();
  void _addRecipe(Recipe recipe) {
    setState(() {
      _recipeRepository.addRecipe(recipe);
    });

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const RecipePage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Recipe'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Title',
                    hintText: "Enter title"),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Description',
                    hintText: "Enter description"),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ingredients',
                    hintText: "Enter ingredients"),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    ingredients.add(_ingredientsController.text);
                    _ingredientsController.clear();
                  });
                },
                child: const Text('Add Ingredient'),
              ),
              const SizedBox(
                height: 20,
              ),
              Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    "Enterd Ingredient :  ${ingredients.toString()}",
                    style: const TextStyle(fontSize: 20),
                  )),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  _addRecipe(Recipe(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      ingredients: ingredients));
                },
                child: const Text('Save Recipe'),
              ),
            ],
          ),
        ));
  }
}

//One recipe page
class OneRecipe extends StatelessWidget {
  final Recipe? recipe;
  const OneRecipe(this.recipe, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("one recipe"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Title : ${recipe!.title.toString()}"),
            Text("Description : ${recipe!.description.toString()}"),
            Text("Ingredients : ${recipe!.ingredients.toString()}"),
          ],
        ),
      ),
    );
  }
}

//Update recipe page
class UpdateRecipe extends StatefulWidget {
  final Recipe? recipe;
  const UpdateRecipe(this.recipe, {super.key});

  @override
  State<UpdateRecipe> createState() => _UpdateRecipeState();
}

class _UpdateRecipeState extends State<UpdateRecipe> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final RecipeRepository recipeRepository = RecipeRepository();

  @override
  Widget build(BuildContext context) {
    _titleController.text = widget.recipe!.title.toString();
    _descriptionController.text = widget.recipe!.description.toString();

    void _updateRecipe(Recipe recipe) {
      setState(() {
        recipeRepository.updateRecipe(recipe);
      });

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const RecipePage();
      }));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Title',
                  hintText: "Enter title"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                  hintText: "Enter description"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'New ingredients',
                  hintText: "Enter new ingredients"),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    widget.recipe!.ingredients
                        ?.add(_ingredientsController.text.toString());

                    _ingredientsController.clear();
                  });
                },
                child: const Text("Add New Ingredient")),
            const SizedBox(
              height: 10,
            ),
            Text("Ingredients: ${widget.recipe!.ingredients}"),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                _updateRecipe(Recipe(
                    id: widget.recipe!.id,
                    title: _titleController.text,
                    description: _descriptionController.text,
                    ingredients: widget.recipe!.ingredients));
              },
              child: const Text('Update Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
