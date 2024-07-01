import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { notification, Button } from 'antd';
import './AddUserForm.css';

const AddUserForm = () => {
  const [userName, setUserName] = useState('');
  const [password, setPassword] = useState('');
  const [email, setEmail] = useState('');
  const [fullName, setFullName] = useState('');
  const [image, setImage] = useState(null);
  const navigate = useNavigate();

  const handleFileChange = (e) => {
    setImage(e.target.files[0]);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const formData = new FormData();
    formData.append('userName', userName);
    formData.append('password', password);
    formData.append('email', email);
    formData.append('fullName', fullName);
    if (image) formData.append('image', image);

    try {
      const response = await axios.post('http://localhost:5000/api/users', formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      });
      notification.success({
        message: 'User Added',
        description: 'User has been successfully added.',
      });
      console.log('New User ID:', response.data._id); // Display the generated user ID
      navigate('/users');
    } catch (error) {
      console.error('Error adding user:', error);
      notification.error({
        message: 'Add User Failed',
        description: 'There was an error adding the user.',
      });
    }
  };

  const handleCancel = () => {
    navigate('/users');
  };

  return (
    <form className="add-user-form" onSubmit={handleSubmit}>
      <h2>Add User</h2>
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
          required
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
          Add User
        </Button>
        <Button type="default" onClick={handleCancel} style={{ backgroundColor: 'red', color: 'white' }}>
          Cancel
        </Button>
      </div>
    </form>
  );
};

export default AddUserForm;
