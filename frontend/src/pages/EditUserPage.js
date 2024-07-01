import React, { useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { notification, Button } from 'antd';
import '../components/AddUserForm.css';

const EditUserPage = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { user } = location.state;

  const [userName, setUserName] = useState(user.userName);
  const [password, setPassword] = useState('');
  const [email, setEmail] = useState(user.email);
  const [fullName, setFullName] = useState(user.fullName);
  const [image, setImage] = useState(null);

  const handleFileChange = (e) => {
    setImage(e.target.files[0]);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const formData = new FormData();
    formData.append('userName', userName);
    if (password) formData.append('password', password); // Hanya kirim password jika diubah
    formData.append('email', email);
    formData.append('fullName', fullName);
    if (image) formData.append('image', image);

    try {
      await axios.put(`http://localhost:5000/api/users/${user._id}`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      });
      notification.success({
        message: 'User Updated',
        description: 'User has been successfully updated.',
      });
      navigate('/users');
    } catch (error) {
      console.error('Error updating user:', error);
      notification.error({
        message: 'Update Failed',
        description: 'There was an error updating the user.',
      });
    }
  };

  const handleCancel = () => {
    navigate('/users');
  };

  return (
    <form className="add-user-form" onSubmit={handleSubmit}>
      <h2>Edit User</h2>
      <label>
        Username:
        <input
          type="text"
          value={userName}
          onChange={(e) => setUserName(e.target.value)}
          required
        />
      </label>
      <label>
        Password:
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
      </label>
      <label>
        Email:
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
        />
      </label>
      <label>
        Full Name:
        <input
          type="text"
          value={fullName}
          onChange={(e) => setFullName(e.target.value)}
          required
        />
      </label>
      <label>
        Image:
        <input
          type="file"
          onChange={handleFileChange}
        />
      </label>
      <div className="form-buttons">
        <Button type="primary" htmlType="submit" style={{ marginRight: '10px' }}>
          Update User
        </Button>
        <Button type="default" onClick={handleCancel} style={{ backgroundColor: 'red', color: 'white' }}>
          Cancel
        </Button>
      </div>
    </form>
  );
};

export default EditUserPage;
