// Simple test script to verify the backend server is working
const http = require('http');

const testEndpoint = (method, path, data = null) => {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const req = http.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const parsed = JSON.parse(responseData);
          resolve({ status: res.statusCode, data: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, data: responseData });
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
};

async function runTests() {
  console.log('🧪 Testing Backend Server...\n');

  try {
    // Test 1: Health check
    console.log('1. Testing health endpoint...');
    const healthResponse = await testEndpoint('GET', '/health');
    console.log(`   Status: ${healthResponse.status}`);
    console.log(`   Response: ${JSON.stringify(healthResponse.data)}`);
    
    if (healthResponse.status === 200) {
      console.log('   ✅ Health check passed\n');
    } else {
      console.log('   ❌ Health check failed\n');
    }

    // Test 2: Approve event (with dummy data)
    console.log('2. Testing approve-event endpoint...');
    const approveResponse = await testEndpoint('POST', '/approve-event', {
      docId: 'test-doc-id-123'
    });
    console.log(`   Status: ${approveResponse.status}`);
    console.log(`   Response: ${JSON.stringify(approveResponse.data)}`);
    
    if (approveResponse.status === 404) {
      console.log('   ✅ Endpoint working (404 expected for non-existent doc)\n');
    } else if (approveResponse.status === 200) {
      console.log('   ✅ Endpoint working (event approved)\n');
    } else {
      console.log('   ❌ Unexpected response\n');
    }

    // Test 3: Reject event (with dummy data)
    console.log('3. Testing reject-event endpoint...');
    const rejectResponse = await testEndpoint('POST', '/reject-event', {
      docId: 'test-doc-id-123'
    });
    console.log(`   Status: ${rejectResponse.status}`);
    console.log(`   Response: ${JSON.stringify(rejectResponse.data)}`);
    
    if (rejectResponse.status === 200 || rejectResponse.status === 404) {
      console.log('   ✅ Endpoint working\n');
    } else {
      console.log('   ❌ Unexpected response\n');
    }

    // Test 4: Invalid request
    console.log('4. Testing error handling...');
    const errorResponse = await testEndpoint('POST', '/approve-event', {});
    console.log(`   Status: ${errorResponse.status}`);
    console.log(`   Response: ${JSON.stringify(errorResponse.data)}`);
    
    if (errorResponse.status === 400) {
      console.log('   ✅ Error handling working\n');
    } else {
      console.log('   ❌ Error handling not working as expected\n');
    }

    console.log('🎉 All tests completed!');
    console.log('\n📝 Next steps:');
    console.log('1. Start the backend server: npm start');
    console.log('2. Create a test event request in Firebase');
    console.log('3. Try approving it through the Flutter admin panel');
    console.log('4. Check if the event appears in the organizer dashboard');

  } catch (error) {
    console.error('❌ Error running tests:', error.message);
    console.log('\n💡 Make sure the backend server is running on localhost:3000');
    console.log('   Run: npm start');
  }
}

runTests();
