enum RecyclingLogoCategory {
  recyclable,
  contribution,
  instruction,
  material,
  uncategorized,
}

extension RecyclingLogoCategoryExtension on RecyclingLogoCategory {
  String get label {
    switch (this) {
      case RecyclingLogoCategory.recyclable:
        return 'Recyclable';
      case RecyclingLogoCategory.contribution:
        return 'Contribution';
      case RecyclingLogoCategory.instruction:
        return 'Instruction';
      case RecyclingLogoCategory.material:
        return 'Matériau';
      case RecyclingLogoCategory.uncategorized:
        return 'Non catégorisé';
    }
  }

  List<RecyclingLogo> get logos {
    return recyclingLogos.where((logo) => logo.category == this).toList();
  }}

class RecyclingLogo {
  final String imagePath;
  final String title;
  final String description;
  final RecyclingLogoCategory category;

  const RecyclingLogo({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.category,
  });
}

final List<RecyclingLogo> recyclingLogos = [
  const RecyclingLogo(
      imagePath: "assets/mobius_circle.svg",
      title: "Cercle de Möbius",
      description: "Le cercle de Möbius (aussi appelé boucle, anneau ou ruban) "
          "est le symbole universel des matériaux recyclables, et ce, depuis "
          "1970. Maintenant très commun, il sert à identifier un produit comme "
          "étant récupérable. Si le cercle inclut un pourcentage au centre, la "
          "signification change du tout au tout. Le pourcentage indique que "
          "l’article ou l’emballage contient une certaine quantité de matières "
          "recyclées.",
      category: RecyclingLogoCategory.recyclable,
  ),
  const RecyclingLogo(
      imagePath: "assets/point_vert.svg",
      title: "Point Vert",
      description: "Le Point Vert est un symbole de recyclage très populaire en "
          "Europe. Il est apposé sur les emballages pour indiquer que le "
          "producteur a contribué financièrement à la collecte sélective et au "
          "recyclage de l’emballage. Il ne signifie pas que l’emballage est "
          "recyclable.",
      category: RecyclingLogoCategory.contribution,
  ),
  const RecyclingLogo(
      imagePath: "assets/triman.svg",
      title: "Triman",
      description: "Triman est né en 2015. Il est apposé obligatoirement sur "
          "tous les emballages et produits recyclables, sauf les contenants en "
          "verre. Il signifie que le produit est récupérable. Symboliquement, "
          "la silhouette sert à démontrer l’action citoyenne, les trois flèches "
          "représentent le tri et la flèche circulaire incarne le recyclage.",
      category: RecyclingLogoCategory.recyclable,
  ),
  const RecyclingLogo(
    imagePath: "assets/tidyman.svg",
    title: "Tidyman",
    description: "Le Tidyman est un symbole international qui indique que le "
        "produit ou l’emballage doit être jeté dans une poubelle. Il est "
        "utilisé pour encourager les gens à jeter leurs déchets dans une "
        "poubelle plutôt que par terre.",
    category: RecyclingLogoCategory.instruction,
  ),
  const RecyclingLogo(
      imagePath: "assets/poubelle_barree.svg",
      title: "Poubelle barrée",
      description: "Ce symbole indique que le produit ou l’emballage ne doit "
          "pas être jeté dans une poubelle. Il est souvent accompagné de la "
          "mention « Ne pas jeter à la poubelle ». Il est utilisé pour "
          "encourager les gens à recycler ou à composter.",
      category: RecyclingLogoCategory.instruction,
  ),
  const RecyclingLogo(
      imagePath: "assets/acier_recyclable.svg",
      title: "Acier recyclable",
      description: "Ce symbole indique que l’emballage est recyclable. Il est "
          "souvent accompagné de la mention « Veuillez recycler ». Il est "
          "important de noter que ce symbole ne signifie pas que l’emballage "
          "est fait de matières recyclées.",
      category: RecyclingLogoCategory.material,
  ),
  const RecyclingLogo(
      imagePath: "assets/aluminium_recyclable.svg",
      title: "Aluminium recyclable",
      description: "Ce symbole indique que l’emballage est recyclable. Il est "
          "souvent accompagné de la mention « Veuillez recycler ». Il est "
          "important de noter que ce symbole ne signifie pas que l’emballage "
          "est fait de matières recyclées.",
      category: RecyclingLogoCategory.material,
  ),
  const RecyclingLogo(
      imagePath: "assets/verre_recyclable.svg",
      title: "Verre recyclable",
      description: "Ce symbole indique que l’emballage est recyclable. Il est "
          "souvent accompagné de la mention « Veuillez recycler ». Il est "
          "important de noter que ce symbole ne signifie pas que l’emballage "
          "est fait de matières recyclées.",
      category: RecyclingLogoCategory.material,
  ),
];
