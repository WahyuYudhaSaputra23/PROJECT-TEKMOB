import React from 'react';
import { FaPencilAlt, FaTrash } from 'react-icons/fa';
import './Table.css';

const UserTable = ({ users, onEdit, onDelete }) => {
  return (
    <table className="table">
      <thead>
        <tr>
          <th className="user-id-column">User ID</th>
          <th>Username</th>
          <th>Email</th>
          <th>Full Name</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        {users.map((user) => (
          <tr key={user._id}>
            <td className="user-id-column">{user._id}</td>
            <td>{user.userName}</td>
            <td>{user.email}</td>
            <td>{user.fullName}</td>
            <td>
              <div className="btn-container">
                <button className="btn-edit" onClick={() => onEdit(user)}>
                  <FaPencilAlt /> Edit
                </button>
                <button className="btn-delete" onClick={() => onDelete(user._id)}>
                  <FaTrash /> Delete
                </button>
              </div>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default UserTable;
