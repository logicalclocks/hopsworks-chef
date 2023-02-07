DROP TABLE `shared_topics`;
DROP TABLE `topic_acls`;

UPDATE `project_team`
SET team_role = 'Data owner'
WHERE team_member = 'serving@hopsworks.se';
