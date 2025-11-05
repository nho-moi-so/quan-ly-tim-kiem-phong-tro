#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

// Lấy tên component từ command line
const componentName = process.argv[2];

if (!componentName) {
  console.error("❌ Vui lòng cung cấp tên component!");
  console.log("📝 Cách dùng: node generate-component.js <ComponentName>");
  process.exit(1);
}

// Capitalize first letter
const capitalizedName =
  componentName.charAt(0).toUpperCase() + componentName.slice(1);

// Đường dẫn
const componentsDir = path.join(process.cwd(), "src", "components");
const componentDir = path.join(componentsDir, capitalizedName);
const componentFile = path.join(componentDir, `${capitalizedName}.tsx`);
const indexFile = path.join(componentsDir, "index.ts");

// Template cho component
const componentTemplate = `import React from 'react';

interface ${capitalizedName}Props {
  // Add your props here
}

export const ${capitalizedName}: React.FC<${capitalizedName}Props> = (props) => {
  return (
    <div>
      <h2>${capitalizedName} Component</h2>
    </div>
  );
};

export default ${capitalizedName};
`;

try {
  // 1. Tạo folder components nếu chưa có
  if (!fs.existsSync(componentsDir)) {
    fs.mkdirSync(componentsDir, { recursive: true });
    console.log("✅ Đã tạo folder components");
  }

  // 2. Tạo folder component
  if (fs.existsSync(componentDir)) {
    console.error(`❌ Component "${capitalizedName}" đã tồn tại!`);
    process.exit(1);
  }

  fs.mkdirSync(componentDir, { recursive: true });
  console.log(`✅ Đã tạo folder: ${capitalizedName}`);

  // 3. Tạo file component
  fs.writeFileSync(componentFile, componentTemplate);
  console.log(`✅ Đã tạo file: ${capitalizedName}.tsx`);

  // 4. Cập nhật hoặc tạo file index.ts
  let indexContent = "";

  if (fs.existsSync(indexFile)) {
    indexContent = fs.readFileSync(indexFile, "utf-8");
  }

  // Kiểm tra xem đã export chưa
  const exportLine = `export * from './${capitalizedName}/${capitalizedName}';\n`;

  if (!indexContent.includes(exportLine)) {
    indexContent += exportLine;
    fs.writeFileSync(indexFile, indexContent);
    console.log("✅ Đã thêm export vào index.ts");
  }

  console.log("\n🎉 Tạo component thành công!");
  console.log(`\n📦 Cách sử dụng:`);
  console.log(`import { ${capitalizedName} } from '@/components';`);
  console.log(`\nhoặc:`);
  console.log(
    `import ${capitalizedName} from '@/components/${capitalizedName}/${capitalizedName}';`
  );
} catch (error) {
  console.error("❌ Có lỗi xảy ra:", error.message);
  process.exit(1);
}
