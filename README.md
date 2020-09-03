#How To

## Restore locally a dump from heroku 
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U denisjacquemin -d s2p_development '/Users/denisjacquemin/Documents/Konecto App/Backups/...'


Extract Saint Vincent from Bellefontaine

bellefontaine_school_id = 89
saint_vincent_school_id = 203

all_student_bellefontaine_group_id = Group.where(internal_id: 'all_students', school_id: 89).pluck(:id).first # 414904
all_student_saint_vincent = Group.where(internal_id: 'all_students', school_id: 203).pluck(:id).first # 419942

groups = Group.find(415192, 415190, 415189, 415150, 415191, 415193, 415179, 415141, 415181, 415182, 415938, 419941, 415924)
students = Student.by_groups([415192, 415190, 415189, 415150, 415191, 415193, 415179, 415141, 415181, 415182, 415938, 419941,415924]).count

# retirer all_student_bellefontaine des students
students.each { |student| student.groups.delete(414904); student.save }

# ajouter all_student_saint_vincent aux students
students.each { |student| student.groups.push(419942); student.save }

# changer le school_id de groups et students
students.each { |student| student.school_id = 203; student.save }
groups.each { |group| group.school_id = 203; group.save }

# sepration de l'ecole st francaois auvelais en 2 implanatations
groups = [424626, 420971, 420981, 420995, 420977, 420990, 420986, 420975, 420969, 421377]
Student.by_groups(groups).update_all(school_id: )
Group.by_ids(groups).update_all(school_id: )
Student.where(school_id: ).each {|s| s.groups = s.groups - [419493]; s.save}
Student.where(school_id: ).each {|s| s.groups = s.groups + [424116]; s.save} 

Student.by_group(420949).each {|s| s.groups = s.groups - [420949]; s.save}


repasser pour chaque redacteur, attribuer l'accès a à la nouvelle implantation et les droits d'acces aux groupes


heroku pg:bloat postgresql-deep-44022 --app s2p-prod-16
heroku pg:vacuum_stats postgresql-deep-44022 --app s2p-prod-16

heroku pg:bloat postgresql-pointy-51752 --app s2p-prod



Clean Message table

Message.where("title = ? and created_at <?", "Les informations de l'école via Konecto App", 1.years.ago).count


# Supprimer les titulaires d'une école

s = School.find 

s.students.update_all(classroom: '')

Group.find(420883).students.each { |student| student.groups.delete(420883); student.save }

## Extraire tous les messages pour un auteur en CSV

1. rails db
2. COPY (SELECT title, content, created_at from messages WHERE author_id = '3458' ORDER BY created_at) TO '/Users/denisjacquemin/Documents/messages_partial_db.csv' DELIMITER ';' CSV HEADER;