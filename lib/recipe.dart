class Recipe {
  String? id;
  String? title;
  String? description;
  List<String>? ingredients;

  Recipe({this.id, this.title, this.description, this.ingredients});

  Recipe.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    ingredients = json['ingredients'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['ingredients'] = this.ingredients;
    return data;
  }
}
