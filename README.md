A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.

## Register a user
Use the command `register username password` to register a new user on the platform.
## Login
Use `login username password` to login as an existing user. Note that only one user can be logged in during a session.
## Logout
Use `logout` to logout of the session.
## Create a server
Use `create-server server_name` to create a new server.  You will automatically be marked as the owner of that server and gain the ability to add other users, add categories, channels and manage permissions.
## Add users to a server
Use `add-member server_name user_name` to add existing users to a server. Ypu must be logged in to do so. The added user will automatically be given member privileges.
## Add categories to a server
Use `add-category server_name category_name` to add a category to a server (requires owner privileges). The newly added category will not have any channels in it by default.
## Add channels to a server
Use `add-channel server_name channel_name channel_perms channel_type parent_category` , with the parent_category flag being optional. (requires owner privileges). By default, the channel will not belong to any category.
Channels can have three levels of permission - member, moderator, and owner, allowing varying levels of access. Channels currently support three types - text, voice and video.
## Send message in a server
Use `send-msg server_name channel_name`, to send a message in a text channel. (Can be done only while logged in). You will then be prompted to enter your message. 
## Displaying users, servers, channels, roles and messages
Use the format `display-item` to display a list of said item. Here, users, servers, channels and messages are currently supported.
NOTE : specify server_name for display-messages and display-roles.
## Sending direct messages to other users
Use `dm receiver_name` and enter the message upon being prompted. Use `show-dms user` to show dm history with the user mentioned. (requires login).
## Creating a new role for a server
Use `create-role server_name role_name role_permission` to create a new role for a server (owner privileges required). Note that role names must be unique for a server. Permissions can be - owner, moderator or member (by default).
## Assign an existing role in a server to a member
Use `assign-role server_name role_name member_name` to assign a role in a server to a member (owner privileges required).
## Adding channels to categories for a server (Owner only)
Use `channel-to-cat server_name channel_name category_name` to assign an existing channel in that server to an existing category. 
## Changing permissions for a channel (Owner only)
Use `change-perm server_name channel_name new_perm` to change the permissions for an existing channel in server_name. Permissions can be - member, moderator or owner.
