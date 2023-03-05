import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lab_activity/recipe.dart';

class RecipeRepository {
  final CollectionReference _recipeCollection =
      FirebaseFirestore.instance.collection('recipes');

  //Get All Recipes
  Future<List<Recipe>> getAllRecipes() async {
    final QuerySnapshot snapshot = await _recipeCollection.get();

    return snapshot.docs.map((doc) {
      return Recipe(
        id: doc.id,
        title: doc['title'],
        description: doc['description'],
        ingredients: List<String>.from(doc['ingredients']),
      );
    }).toList();
  }

  //Delete Recipe by ID
  Future<void> deleteRecipe(String id) async {
    await _recipeCollection.doc(id).delete();
  }

  //Update Recipe by ID
  Future<void> updateRecipe(Recipe recipe) async {
    await _recipeCollection.doc(recipe.id).update({
      'title': recipe.title,
      'description': recipe.description,
      'ingredients': recipe.ingredients,
    });
  }

  //Add Recipe
  Future<void> addRecipe(Recipe recipe) async {
    await _recipeCollection.add({
      'title': recipe.title,
      'description': recipe.description,
      'ingredients': recipe.ingredients,
    });
  }
}
