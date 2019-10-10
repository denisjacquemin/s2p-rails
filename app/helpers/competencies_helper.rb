module CompetenciesHelper

    def init_competencies(school_id)
        c1 = Comptecency.create(name: 'Français', level: 1)
        Comptecency.create(name: 'Lire', level: 2, parent_id: c1.id)
    end
end
