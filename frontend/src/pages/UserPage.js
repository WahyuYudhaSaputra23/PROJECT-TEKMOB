import React, { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import axios from 'axios';
import UserTable from '../components/UserTable';
import './UserPage.css';
import { Modal } from 'antd';

const UserPage = () => {
  const [users, setUsers] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const response = await axios.get('http://localhost:5000/api/users');
      setUsers(response.data);
    } catch (error) {
      console.error('Error fetching users:', error);
    }
  };

  const handleEdit = (user) => {
    navigate(`/edit-user/${user._id}`, { state: { user } });
  };

  const handleDelete = (userId) => {
    Modal.confirm({
      title: 'Are you sure you want to delete this user?',
      content: 'This action cannot be undone.',
      onOk: async () => {
        console.log('Deleting user with ID:', userId);
        try {
          await axios.delete(`http://localhost:5000/api/users/${userId}`);
          fetchUsers(); // Refresh data users setelah delete
        } catch (error) {
          console.error('Error deleting user:', error);
        }
      },
      onCancel() {
        console.log('Delete action cancelled');
      },
    });
  };

  return (
    <div className="page">
      <div className="page-header">
        <h1>Users</h1>
        <Link to="/add-user" className="btn-add-user">Add User</Link>
      </div>
      <UserTable users={users} onEdit={handleEdit} onDelete={handleDelete} />
    </div>
  );
};

export default UserPage;
