from flask_migrate import Migrate, MigrateCommand
from flask_script import Manager
from app import create_app
from models import db

# Import model untuk memastikan SQLAlchemy mengenalinya
from models.user import User

app = create_app()
migrate = Migrate(app, db)
manager = Manager(app)
manager.add_command('db', MigrateCommand)

if __name__ == '__main__':
    manager.run()
